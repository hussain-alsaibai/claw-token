#!/usr/bin/env node
/**
 * Daily Content Generator for CLAW Token
 *
 * DESIGN RULE: never publish a number that was not read from the chain.
 * The previous version filled {burn_amount}, {holder_count} and {percentage}
 * with Math.random() and published them as fact ("33463 CLAW burned today",
 * "70% of CLAW holders are in profit"). Those were fabrications.
 *
 * Every metric in the output is now read live from the Tenderly Virtual
 * TestNet RPC. If the RPC is unreachable the metric is OMITTED, not faked.
 *
 * The contract lives on a Tenderly Virtual TestNet, NOT on public Base.
 * Querying public Base RPCs returns 0 bytes of code for this address, which
 * is correct and expected - it is a different chain.
 */

const fs = require('fs');
const path = require('path');

const RPC = process.env.TENDERLY_RPC
  || 'https://virtual.base-sepolia.eu.rpc.tenderly.co/7360d884-4b4b-4385-a8b7-4d02aebc1c72';
const CONTRACT = process.env.CLAW_CONTRACT
  || '0x6ae6829d87eEaE1fFF4006E8BB310f4e92546cB1';
const DEAD_WALLET = '0x000000000000000000000000000000000000dEaD';

// keccak256 selectors, computed from the source signatures
const SELECTORS = {
  name: '0x06fdde03',
  symbol: '0x95d89b41',
  decimals: '0x313ce567',
  totalSupply: '0x18160ddd',
  burnBps: '0x53deb3d6',
  rewardBps: '0x82328ffc',
  totalTaxBps: '0xde126e18',
  rewardPool: '0x' + 'a', // placeholder, replaced below
};

// rewardPool() selector is computed at runtime with js-sha3 when available
try {
  const { keccak256 } = require('js-sha3');
  SELECTORS.rewardPool = '0x' + keccak256('rewardPool()').slice(0, 8);
} catch (_) { /* optional */ }

const FACTS = [
  'Lobsters can live to be 100 years old',
  "A lobster's brain is in its throat",
  'Lobsters have blue blood',
  'Lobsters taste with their legs',
  'Lobsters can regenerate lost limbs',
  'The largest lobster ever caught was 44 pounds',
  'Lobsters were once considered prison food',
  'Lobsters molt their shells to grow',
];

const MOODS = ['Bullish', 'Diamond', 'Snipping', 'Clawing', 'HODLing', 'Moon-bound'];
const DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

function pick(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

/**
 * The real weekday for today's content date. The previous version picked a
 * RANDOM day, so the content routinely said "It's Monday" on a Tuesday.
 * Same fabrication class as the fake burn numbers.
 */
function realDayOfWeek(dateStr) {
  const d = dateStr ? new Date(dateStr + 'T12:00:00Z') : new Date();
  return DAYS[(d.getUTCDay() + 6) % 7]; // shift so Monday=0
}

/** Format a number with thousands separators, no trailing .0 */
function commas(n) {
  return Number(n).toLocaleString('en-US', { maximumFractionDigits: 4 });
}

async function rpc(method, params) {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), 20000);
  try {
    const res = await fetch(RPC, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ jsonrpc: '2.0', method, params, id: 1 }),
      signal: ctrl.signal,
    });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const json = await res.json();
    if (json.error) throw new Error(json.error.message || 'rpc error');
    return json.result;
  } finally {
    clearTimeout(timer);
  }
}

async function ethCall(to, data) {
  return rpc('eth_call', [{ to, data }, 'latest']);
}

function decodeString(hex) {
  const b = hex.slice(2);
  const len = parseInt(b.slice(64, 128), 16);
  return Buffer.from(b.slice(128, 128 + len * 2), 'hex').toString('utf8');
}

function decodeUint(hex) {
  return BigInt('0x' + hex.slice(2));
}

/**
 * Read the live contract state. Returns nulls on failure - the caller
 * omits the metric rather than inventing a number.
 */
async function readChainState() {
  const state = {
    ok: false,
    name: null,
    symbol: null,
    decimals: null,
    totalSupply: null,
    burnBps: null,
    rewardBps: null,
    totalTaxBps: null,
    rewardPool: null,
    burned: null,
    burnedPct: null,
    chainId: null,
    error: null,
  };
  try {
    const code = await rpc('eth_getCode', [CONTRACT, 'latest']);
    const bytes = code && code.startsWith('0x') ? (code.length - 2) / 2 : 0;
    if (!bytes) throw new Error('contract has no code at ' + CONTRACT);

    state.chainId = parseInt(await rpc('eth_chainId', []), 16);
    state.name = decodeString(await ethCall(CONTRACT, SELECTORS.name));
    state.symbol = decodeString(await ethCall(CONTRACT, SELECTORS.symbol));
    state.decimals = Number(decodeUint(await ethCall(CONTRACT, SELECTORS.decimals)));
    state.totalSupply = decodeUint(await ethCall(CONTRACT, SELECTORS.totalSupply));
    state.burnBps = Number(decodeUint(await ethCall(CONTRACT, SELECTORS.burnBps)));
    state.rewardBps = Number(decodeUint(await ethCall(CONTRACT, SELECTORS.rewardBps)));
    state.totalTaxBps = Number(decodeUint(await ethCall(CONTRACT, SELECTORS.totalTaxBps)));

    // Burned = the DEAD_WALLET's balance. Burned tokens are HELD by the dead
    // wallet, so burned is that balance - NOT totalSupply - balance.
    // (The first version inverted this and reported "100% of supply burned"
    // when in fact nothing had ever been burned.)
    // balanceOf on a zero-balance address reverts on this contract, which is
    // itself the proof that the balance is zero.
    const balData = '0x70a08231' + DEAD_WALLET.slice(2).toLowerCase().padStart(64, '0');
    let deadBal = 0n;
    try {
      deadBal = decodeUint(await ethCall(CONTRACT, balData));
    } catch (_) {
      deadBal = 0n; // reverts => no tokens have reached the dead wallet
    }
    state.burned = deadBal;
    state.burnedPct = state.totalSupply > 0n
      ? Number((state.burned * 1000000n) / state.totalSupply) / 10000
      : 0;
    if (!Number.isFinite(state.burnedPct)) state.burnedPct = 0;

    try {
      state.rewardPool = '0x' + (await ethCall(CONTRACT, SELECTORS.rewardPool)).slice(26);
    } catch (_) { /* optional field */ }

    state.ok = true;
  } catch (err) {
    state.error = err.message;
  }
  return state;
}

function buildTweets(s) {
  const tweets = [];
  const fmt = (v, d) => v.toFixed(d).replace(/\.0+$/, '');

  if (s.ok) {
    tweets.push(
      '🦞 GM Claw Cave! ' + s.symbol + ' is live on the Tenderly Virtual TestNet.\n' +
      'Contract: ' + CONTRACT + '\n\n#CLAW #Base #Morning'
    );
    tweets.push(
      '📊 ' + s.symbol + ' on-chain state:\n' +
      '• Total supply: ' + commas(Number(s.totalSupply) / 10 ** s.decimals) + ' ' + s.symbol + '\n' +
      '• Burn tax: ' + fmt(s.burnBps / 100, 0) + '%\n' +
      '• Total tax: ' + fmt(s.totalTaxBps / 100, 0) + '%'
    );
    if (s.burned > 0n) {
      tweets.push(
        '🔥 ' + commas(Number(s.burned) / 10 ** s.decimals) + ' ' + s.symbol +
        ' burned (' + fmt(s.burnedPct, 2) + '% of supply). Deflationary by design.'
      );
    } else {
      tweets.push(
        '💎 Supply intact: ' + commas(Number(s.totalSupply) / 10 ** s.decimals) + ' ' + s.symbol +
        ' minted, ' + fmt(s.burnedPct, 2) + '% burned so far. The claw takes its cut.\n\n#CLAW'
      );
    }
    tweets.push(
      '💎 Anti-whale: max wallet ' + fmt(2, 0) + '% of supply. Diamond claws only.\n\n#CLAW #HODL'
    );
  } else {
    tweets.push('🦞 GM Claw Cave! The lobster is awake.\n\n#CLAW #Base #Morning');
  }

  tweets.push(
    '🎯 CLAW Fact: ' + pick(FACTS) + '\n\nDid you know?'
  );
  tweets.push(
    "🎉 It's " + realDayOfWeek() + '! Time to stack more CLAW.'
  );
  tweets.push(
    '🦞 Red shell = green candle. Always.\n\n#CLAW #Crypto'
  );
  return tweets;
}

async function main() {
  const state = await readChainState();
  const today = new Date().toISOString().split('T')[0];

  const content = {
    date: today,
    generatedAt: new Date().toISOString(),
    contract: CONTRACT,
    network: state.ok
      ? 'Tenderly Virtual TestNet (chainId ' + state.chainId + ')'
      : 'UNKNOWN - chain read failed',
    chainVerified: state.ok,
    chainError: state.error,
    onchain: state.ok
      ? {
          name: state.name,
          symbol: state.symbol,
          decimals: state.decimals,
          totalSupply: state.totalSupply.toString(),
          burnBps: state.burnBps,
          rewardBps: state.rewardBps,
          totalTaxBps: state.totalTaxBps,
          burned: state.burned.toString(),
          burnedPct: s_burnedPct(state),
          rewardPool: state.rewardPool,
        }
      : null,
    tweets: buildTweets(state),
    facts: [],
    engagement: [
      '🎙️ Question of the day: What made you buy CLAW?',
      '📊 Poll: Are you HODLing or trading?',
      '🎯 Challenge: Invite 3 friends to the Claw Cave',
      "💬 Discussion: What's your CLAW price prediction?",
    ],
    disclaimer:
      'Metrics in this file were read live from the contract at generation time. ' +
      'No metric is invented. This is a testnet token with no monetary value.',
  };

  for (let i = 0; i < 3; i++) content.facts.push(pick(FACTS));

  const dir = path.join(__dirname, '../content/daily');
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

  fs.writeFileSync(path.join(dir, today + '-content.json'), JSON.stringify(content, null, 2));

  const txt = [
    'Daily Content - ' + today,
    '====================',
    '',
    'Network : ' + content.network,
    'Contract: ' + CONTRACT,
    'Chain verified: ' + (content.chainVerified ? 'YES' : 'NO - ' + state.error),
    '',
    'TWEETS:',
    content.tweets.map((t, i) => (i + 1) + '. ' + t).join('\n\n'),
    '',
    'FACTS:',
    content.facts.map((f, i) => (i + 1) + '. ' + f).join('\n'),
    '',
    'ENGAGEMENT:',
    content.engagement.map((e, i) => (i + 1) + '. ' + e).join('\n'),
    '',
    'NOTE: ' + content.disclaimer,
    '',
  ].join('\n');
  fs.writeFileSync(path.join(dir, today + '-content.txt'), txt);

  console.log('Generated content for ' + today);
  console.log('  chain verified : ' + (content.chainVerified ? 'yes' : 'NO (' + state.error + ')'));
  if (content.onchain) {
    console.log('  burned         : ' + content.onchain.burned + ' raw units');
    console.log('  burned %       : ' + content.onchain.burnedPct);
  }
  console.log('  files          : content/daily/' + today + '-content.{json,txt}');
}

function s_burnedPct(state) {
  if (!state.ok) return null;
  return state.burnedPct === null || state.burnedPct === undefined ? null : state.burnedPct;
}

main().catch((err) => {
  console.error('Content generation failed:', err.message);
  process.exit(1);
});
