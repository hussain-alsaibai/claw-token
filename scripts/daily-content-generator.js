#!/usr/bin/env node
/**
 * Daily Content Generator for CLAW Token
 * Creates tweet ideas, memes, and engagement content
 */

const fs = require('fs');
const path = require('path');

const TEMPLATES = {
  tweets: [
    "🦞 GM Claw Cave! Today's energy: {mood}\n\n#CLAW #Base #Morning",
    "🎯 CLAW Fact #{number}: {fact}\n\nDid you know?",
    "💎 Diamond claws don't paper hand. They HODL.\n\n#CLAW #HODL",
    "🚀 {percentage}% of CLAW holders are in profit. Are you?",
    "🦞 Red shell = Green candle. Always.\n\n#CLAW #Crypto",
    "🔥 {burn_amount} CLAW burned today. Deflationary by design.",
    "💰 {holder_count} diamond claws and counting!\n\n#CLAWCommunity",
    "🎉 It's {day_of_week}! Time to stack more CLAW.",
  ],
  
  facts: [
    "Lobsters can live to be 100 years old",
    "A lobster's brain is in its throat",
    "Lobsters have blue blood",
    "Lobsters taste with their legs",
    "Lobsters can regenerate lost limbs",
    "The largest lobster ever caught was 44 pounds",
    "Lobsters were once considered prison food",
    "Lobsters molt their shells to grow",
  ],
  
  moods: ["Bullish", "Diamond", "Snipping", "Clawing", "HODLing", "Moon-bound"],
  
  days: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
};

function getRandom(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function generateDailyContent() {
  const today = new Date().toISOString().split('T')[0];
  const content = {
    date: today,
    tweets: [],
    facts: [],
    engagement: []
  };
  
  // Generate 5 tweets
  for (let i = 0; i < 5; i++) {
    let tweet = getRandom(TEMPLATES.tweets);
    tweet = tweet.replace('{mood}', getRandom(TEMPLATES.moods));
    tweet = tweet.replace('{number}', Math.floor(Math.random() * 50) + 1);
    tweet = tweet.replace('{fact}', getRandom(TEMPLATES.facts));
    tweet = tweet.replace('{percentage}', Math.floor(Math.random() * 80) + 10);
    tweet = tweet.replace('{burn_amount}', (Math.random() * 1000000).toFixed(0));
    tweet = tweet.replace('{holder_count}', (Math.random() * 5000 + 100).toFixed(0));
    tweet = tweet.replace('{day_of_week}', getRandom(TEMPLATES.days));
    content.tweets.push(tweet);
  }
  
  // Generate 3 facts
  for (let i = 0; i < 3; i++) {
    content.facts.push(getRandom(TEMPLATES.facts));
  }
  
  // Engagement prompts
  content.engagement = [
    "🎙️ Question of the day: What made you buy CLAW?",
    "📊 Poll: Are you HODLing or trading?",
    "🎯 Challenge: Invite 3 friends to the Claw Cave",
    "💬 Discussion: What's your CLAW price prediction?",
  ];
  
  return content;
}

function saveContent(content) {
  const dir = path.join(__dirname, '../content/daily');
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  const filename = path.join(dir, `${content.date}-content.json`);
  fs.writeFileSync(filename, JSON.stringify(content, null, 2));
  
  // Also create human-readable version
  const txtFilename = path.join(dir, `${content.date}-content.txt`);
  const txtContent = `Daily Content - ${content.date}
==================

TWEETS:
${content.tweets.map((t, i) => `${i+1}. ${t}`).join('\n\n')}

FACTS:
${content.facts.map((f, i) => `${i+1}. ${f}`).join('\n')}

ENGAGEMENT:
${content.engagement.map((e, i) => `${i+1}. ${e}`).join('\n')}
`;
  fs.writeFileSync(txtFilename, txtContent);
  
  console.log(`✅ Generated content for ${content.date}`);
  console.log(`   Saved: ${filename}`);
  console.log(`   Saved: ${txtFilename}`);
}

// Run
const content = generateDailyContent();
saveContent(content);

console.log('\n🦞 CLAW Daily Content Ready!');
