#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { TrueNASBackupStack } from './backup/truenas-backup-stack';

const app = new cdk.App();

const region = 'eu-north-1';
//const globalRegion = "us-east-1"

new TrueNASBackupStack(app, 'TrueNASBackupStack', {
  description: 'IAM User for TrueNAS backup synchronization',
  env: {
    region,
  },
});

app.synth();
