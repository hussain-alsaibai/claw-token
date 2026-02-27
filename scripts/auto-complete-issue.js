#!/usr/bin/env node
/**
 * Auto-complete GitHub Issue when deployment detected
 * Runs continuously and closes issue #1 when contract is deployed
 */

const https = require('https');

const CONFIG = {
  repo: 'hussain-alsaibai/claw-token',
  issueNumber: 1,
  checkInterval: 600000, // 10 minutes
  tenderlyVNet: 'claw-token-vnet'
};

async function getContractAddress() {
  // Check if deployment.json exists in repo
  return new Promise((resolve) => {
    const options = {
      hostname: 'raw.githubusercontent.com',
      path: `/${CONFIG.repo}/main/deployment.json`,
      method: 'GET'
    };
    
    const req = https.request(options, (res) => {
      if (res.statusCode !== 200) {
        resolve(null);
        return;
      }
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const deployment = JSON.parse(data);
          resolve(deployment.contractAddress);
        } catch (e) {
          resolve(null);
        }
      });
    });
    req.on('error', () => resolve(null));
    req.setTimeout(5000, () => { req.destroy(); resolve(null); });
    req.end();
  });
}

async function closeIssue(contractAddress) {
  const token = process.env.GITHUB_TOKEN || '';
  if (!token) {
    console.log('❌ No GitHub token available');
    return false;
  }
  
  const updateData = {
    state: 'closed',
    body: `## 🎉 DEPLOYMENT COMPLETE!\n\nContract successfully deployed!\n\n**Contract Address:** ${contractAddress}\n**Network:** Tenderly Virtual TestNet (Base Sepolia)\n**Explorer:** https://dashboard.tenderly.co/Alsaibai/project/project/vnet/claw-token-vnet/contracts/${contractAddress}\n\n**Website:** https://hussain-alsaibai.github.io/claw-token/\n\nCLAW Token is LIVE! 🦞🚀\n\n---\n*Auto-closed by deployment monitor*`
  };
  
  return new Promise((resolve) => {
    const options = {
      hostname: 'api.github.com',
      path: `/repos/${CONFIG.repo}/issues/${CONFIG.issueNumber}`,
      method: 'PATCH',
      headers: {
        'Authorization': `token ${token}`,
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
        'User-Agent': 'CLAW-Monitor'
      }
    };
    
    const req = https.request(options, (res) => {
      console.log(`   Issue update status: ${res.statusCode}`);
      resolve(res.statusCode === 200);
    });
    req.on('error', () => resolve(false));
    req.write(JSON.stringify(updateData));
    req.end();
  });
}

async function main() {
  console.log('\n🔍 Checking for deployment...');
  
  const contractAddress = await getContractAddress();
  
  if (contractAddress) {
    console.log(`✅ Deployment detected! Contract: ${contractAddress}`);
    console.log('📝 Auto-closing GitHub issue #1...');
    
    const closed = await closeIssue(contractAddress);
    if (closed) {
      console.log('✅ Issue #1 closed successfully!');
      console.log('🎉 CLAW Token is officially LIVE!');
      process.exit(0);
    } else {
      console.log('⚠️ Could not close issue (no GitHub token)');
    }
  } else {
    console.log('⏳ Deployment not yet detected');
    console.log(`   Checking again