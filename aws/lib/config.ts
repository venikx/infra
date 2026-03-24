export const regions = {
  primary: 'eu-north-1',
  global: 'us-east-1',
} as const;

export type Environment = 'prod' | 'staging' | 'dev';

/**
 * Generate a consistent resource name following the pattern:
 * <app>-<env>-<purpose>
 *
 * @param app Application or service name (e.g., 'truenas', 'web-app')
 * @param env Environment (prod, staging, dev)
 * @param purpose Resource purpose (e.g., 'backup', 'api', 'database')
 * @returns Formatted resource name
 *
 * @example
 * resourceName('truenas', 'prod', 'backup') // => 'truenas-prod-backup'
 */
export function resourceName(app: string, env: Environment, purpose: string): string {
  return `${app}-${env}-${purpose}`;
}
