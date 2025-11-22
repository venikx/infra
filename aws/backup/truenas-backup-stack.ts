#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';
import { Construct } from 'constructs';
import { resourceName } from '../lib/config';

/**
 * CloudFormation Stack for TrueNAS Backup
 *
 * Creates:
 * - S3 bucket for TrueNAS backups
 * - IAM user with programmatic access scoped to backup folder
 * - Secrets Manager secret for credentials
 */
export class TrueNASBackupStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const userName = resourceName('truenas', 'prod', 'backup');
    const bucketName = resourceName('truenas', 'prod', 'backup-data');
    const secretName = resourceName('truenas', 'prod', 'backup-credentials');
    const backupPrefix = 'data/';

    // S3 Bucket for backups
    const bucket = new s3.Bucket(this, 'TrueNASBackupBucket', {
      bucketName,
      encryption: s3.BucketEncryption.S3_MANAGED,
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      versioned: true,
      lifecycleRules: [
        {
          id: 'DeleteOldVersions',
          noncurrentVersionExpiration: cdk.Duration.days(90),
        },
      ],
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      autoDeleteObjects: true,
    });

    // IAM User
    const user = new iam.User(this, 'TrueNASBackupUser', {
      userName,
      path: '/system/',
    });

    // Policy: List all buckets (required by rclone for discovery)
    user.addToPolicy(
      new iam.PolicyStatement({
        sid: 'ListAllBuckets',
        effect: iam.Effect.ALLOW,
        actions: ['s3:ListAllMyBuckets', 's3:GetBucketLocation'],
        resources: ['*'],
      })
    );

    // Policy: List bucket (with prefix condition)
    user.addToPolicy(
      new iam.PolicyStatement({
        sid: 'ListBucket',
        effect: iam.Effect.ALLOW,
        actions: ['s3:ListBucket'],
        resources: [bucket.bucketArn],
        conditions: {
          StringLike: {
            's3:prefix': [`${backupPrefix}*`],
          },
        },
      })
    );

    // Policy: Read/write objects in backup folder
    user.addToPolicy(
      new iam.PolicyStatement({
        sid: 'ReadWriteBackupFolder',
        effect: iam.Effect.ALLOW,
        actions: ['s3:GetObject', 's3:PutObject', 's3:DeleteObject'],
        resources: [`${bucket.bucketArn}/${backupPrefix}*`],
      })
    );

    const accessKey = new iam.CfnAccessKey(this, 'TrueNASBackupUserAccessKey', {
      userName: user.userName,
    });

    const secret = new secretsmanager.Secret(this, 'TrueNASBackupUserSecret', {
      secretName,
      description: 'Access credentials for TrueNAS backup IAM user',
      secretObjectValue: {
        accessKeyId: cdk.SecretValue.unsafePlainText(accessKey.ref),
        secretAccessKey: cdk.SecretValue.resourceAttribute(accessKey.attrSecretAccessKey),
        bucketName: cdk.SecretValue.unsafePlainText(bucket.bucketName),
        backupPrefix: cdk.SecretValue.unsafePlainText(backupPrefix),
      },
    });

    new cdk.CfnOutput(this, 'BucketNameOutput', {
      description: 'S3 bucket for TrueNAS backups',
      value: bucket.bucketName,
    });

    new cdk.CfnOutput(this, 'BackupPrefixOutput', {
      description: 'S3 prefix for backup data',
      value: backupPrefix,
    });

    new cdk.CfnOutput(this, 'UserNameOutput', {
      description: 'IAM User name for TrueNAS',
      value: user.userName,
    });

    new cdk.CfnOutput(this, 'UserArnOutput', {
      description: 'ARN of the IAM user',
      value: user.userArn,
    });

    new cdk.CfnOutput(this, 'SecretArnOutput', {
      description: 'ARN of the Secrets Manager secret containing credentials',
      value: secret.secretArn,
    });
  }
}
