#!/usr/bin/env node
/**
 * Autonomous Deployment Monitor
 * Checks GitHub Actions and Tenderly for deployment status
 */

const https = require('https');

const CONFIG = {
  githubRepo: 'hussain-alsaibai/claw-token',
  tenderlyVNet: 'claw-token-vnet',
  checkInterval: 300000 // 5 minutes
};

async function checkGitHubActions() {
  console.log('🔍 Checking GitHub Actions...');
  
  // Check if recent workflow runs exist
  const options = {
    hostname: 'api.github.com',
    path: `/repos/${CONFIG.githubRepo}/actions/runs?per_page=5`,
    method: 'GET',
    headers: {
      'User-Agent': 'CLAW-Monitor',
      'Accept': 'application/vnd.github.v3+json'
    }
  };
  
  return new Promise((resolve) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const runs = JSON.parse(data);
          const latestRun = runs.workflow_runs?.[0];
          if (latestRun) {
            console.log(`   Latest run: ${latestRun.status} (${latestRun.conclusion || 'in progress'})`);
            resolve(latestRun.status === 'completed' && latestRun.conclusion === 'success');
          } else {
            resolve(false);
          }
        } catch (e) {
          resolve(false);
        }
      });
    });
    req.on('error', () => resolve(false));
    req.setTimeout(10000, () => { req.destroy(); resolve(false); });
    req.end();
  });
}

async function checkTenderlyDeployment() {
  console.log('🔍 Checking Tenderly Virtual TestNet...');
  
  // Check VNet status via RPC
  const rpcUrl = 'https://virtual.base-sepolia.eu.rpc.tenderly.co/7360d884-4b4b-4385-a8b7-4d02aebc1c72';
  
  return new Promise((resolve) => {
    const req = https.request(rpcUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }, (res) => {
      console.log(`   VNet status: ${res.statusCode === 200 ? '✅ Online' : '❌ Offline'}`);
      resolve(res.statusCode === 200);
    });
    req.on('error', () => { console.log('   VNet status: ❌ Offline'); resolve(false); });
    req.setTimeout(5000, () => { req.destroy(); resolve(false); });
    req.write(JSON.stringify({
      jsonrpc: '2.0',
      method: 'eth_blockNumber',
      params: [],
      id: 1
    }));
    req.end();
  });
}

async function main() {
  console.log('\n🦞 CLAW Token Deployment Monitor');
  console.log('================================');
  console.log(`Time: ${new Date().toISOString()}`);
  
  const [githubReady, tenderlyReady] = await Promise.all([
    checkGitHubActions(),
    checkTenderlyDeployment()
  ]);
  
  console.log('\n📊 Status Report:');
  console.log(`   GitHub Actions: ${githubReady ? '✅ Ready/Deployed' : '⏳ Awaiting Secret'}`);
  console.log(`   Tenderly VNet: ${tenderlyReady ? '✅ Online' : '❌ Offline'}`);
  
  if (githubReady && tenderlyReady) {
    console.log('\n🎉 Deployment Complete! CLAW Token is LIVE!');
  } else if (!githubReady) {
    console.log('\n⏳ Still waiting for GitHub Secret (DEPLOYER_PRIVATE_KEY)');
    console.log('   Add at: https://github.com/hussain-alsaibai/claw-token/settings/secrets/actions');
  }
  
  console.log(`\n⏰ Next check in ${CONFIG.checkInterval/60000} minutes`);
  console.log('================================\n');
}

// Run immediately and then on interval
main();
setInterval(main, CONFIG.checkInterval);
