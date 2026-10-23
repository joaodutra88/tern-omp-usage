-- Answers recorded from omp (`--redact`) and the GitHub API on 2026-10-23, then scrubbed: account ids, e-mails
-- and org names are fake. The test fills in `@NAME@`: `@T+n@` is now + n seconds in epoch ms, `@C5@`/`@CWK@`/`@CF@`
-- are the Claude used fractions, `@X5@`/`@XWK@` the Codex accounts used (of 2), `@VERSION@` the latest release.
return {
	anthropic = [[
{
 "generatedAt": @T+0@,
 "reports": [
  {
   "provider": "anthropic",
   "fetchedAt": @T+0@,
   "limits": [
    {
     "id": "anthropic:5h",
     "label": "Claude 5 Hour",
     "scope": {
      "provider": "anthropic",
      "windowId": "5h",
      "shared": true
     },
     "window": {
      "id": "5h",
      "label": "5 Hour",
      "durationMs": 18000000,
      "resetsAt": @T+9000@
     },
     "amount": {
      "used": 11,
      "limit": 100,
      "remaining": 89,
      "usedFraction": @C5@,
      "remainingFraction": 0.89,
      "unit": "percent"
     },
     "status": "ok"
    },
    {
     "id": "anthropic:7d",
     "label": "Claude 7 Day",
     "scope": {
      "provider": "anthropic",
      "windowId": "7d",
      "shared": true
     },
     "window": {
      "id": "7d",
      "label": "7 Day",
      "durationMs": 604800000,
      "resetsAt": @T+345600@
     },
     "amount": {
      "used": 20,
      "limit": 100,
      "remaining": 80,
      "usedFraction": @CWK@,
      "remainingFraction": 0.8,
      "unit": "percent"
     },
     "status": "ok"
    },
    {
     "id": "anthropic:7d:fable",
     "label": "Claude 7 Day (Fable)",
     "scope": {
      "provider": "anthropic",
      "windowId": "7d",
      "tier": "fable"
     },
     "window": {
      "id": "7d",
      "label": "7 Day",
      "durationMs": 604800000,
      "resetsAt": @T+345600@
     },
     "amount": {
      "used": 3,
      "limit": 100,
      "remaining": 97,
      "usedFraction": @CF@,
      "remainingFraction": 0.97,
      "unit": "percent"
     },
     "status": "ok"
    }
   ],
   "metadata": {
    "accountId": "acct-1",
    "email": "user@example.com",
    "orgId": "acct-1",
    "orgName": "Example",
    "endpoint": "https://api.anthropic.com/api/oauth/usage",
    "headersUpdatedAt": @T+0@
   },
   "resetCredits": {
    "availableCount": 0,
    "redeemableCount": 0,
    "eligible": false,
    "reason": "no_grant",
    "credits": []
   }
  }
 ],
 "accountsWithoutUsage": [],
 "disabledCredentials": [],
 "capacity": {
  "anthropic": [
   {
    "window": "5h",
    "durationMs": 18000000,
    "accounts": 1,
    "usedAccounts": 0.11,
    "remainingAccounts": 0.89
   },
   {
    "window": "7d",
    "durationMs": 604800000,
    "accounts": 1,
    "usedAccounts": 0.2,
    "remainingAccounts": 0.8
   },
   {
    "window": "7d",
    "durationMs": 604800000,
    "meter": "fable",
    "accounts": 1,
    "usedAccounts": 0.03,
    "remainingAccounts": 0.97
   }
  ]
 }
}
]],
	codex = [[
{
 "generatedAt": @T+0@,
 "reports": [
  {
   "provider": "openai-codex",
   "fetchedAt": @T+0@,
   "limits": [
    {
     "id": "openai-codex:primary",
     "label": "5 hours",
     "scope": {
      "provider": "openai-codex",
      "windowId": "5h",
      "shared": true
     },
     "window": {
      "id": "5h",
      "label": "5 hours",
      "durationMs": 18000000,
      "resetsAt": @T+12000@
     },
     "amount": {
      "used": 0,
      "limit": 100,
      "remaining": 100,
      "usedFraction": 0,
      "remainingFraction": 1,
      "unit": "percent"
     },
     "status": "ok"
    },
    {
     "id": "openai-codex:secondary",
     "label": "7 days",
     "scope": {
      "provider": "openai-codex",
      "windowId": "7d",
      "shared": true
     },
     "window": {
      "id": "7d",
      "label": "7 days",
      "durationMs": 604800000,
      "resetsAt": @T+500000@
     },
     "amount": {
      "used": 0,
      "limit": 100,
      "remaining": 100,
      "usedFraction": 0,
      "remainingFraction": 1,
      "unit": "percent"
     },
     "status": "ok"
    }
   ],
   "resetCredits": {
    "availableCount": 2,
    "credits": [
     {
      "grantedAt": "2026-09-29T19:42:22.778580Z",
      "expiresAt": "2026-10-29T19:42:22.778580Z",
      "status": "available"
     },
     {
      "grantedAt": "2026-10-08T00:04:13.781058Z",
      "expiresAt": "2026-11-07T00:04:13.781058Z",
      "status": "available"
     }
    ]
   },
   "metadata": {
    "planType": "team",
    "allowed": true,
    "limitReached": false,
    "email": "user@example.com",
    "accountId": "acct-1",
    "meterStates": {
     "chat": {
      "allowed": true,
      "limitReached": false
     }
    },
    "orgId": "acct-1",
    "orgName": "Example"
   }
  },
  {
   "provider": "openai-codex",
   "fetchedAt": @T+0@,
   "limits": [
    {
     "id": "openai-codex:primary",
     "label": "5 hours",
     "scope": {
      "provider": "openai-codex",
      "windowId": "5h",
      "shared": true
     },
     "window": {
      "id": "5h",
      "label": "5 hours",
      "durationMs": 18000000,
      "resetsAt": @T+12000@
     },
     "amount": {
      "used": 0,
      "limit": 100,
      "remaining": 100,
      "usedFraction": 0,
      "remainingFraction": 1,
      "unit": "percent"
     },
     "status": "ok"
    },
    {
     "id": "openai-codex:secondary",
     "label": "7 days",
     "scope": {
      "provider": "openai-codex",
      "windowId": "7d",
      "shared": true
     },
     "window": {
      "id": "7d",
      "label": "7 days",
      "durationMs": 604800000,
      "resetsAt": @T+500000@
     },
     "amount": {
      "used": 0,
      "limit": 100,
      "remaining": 100,
      "usedFraction": 0,
      "remainingFraction": 1,
      "unit": "percent"
     },
     "status": "ok"
    }
   ],
   "resetCredits": {
    "availableCount": 2,
    "credits": [
     {
      "grantedAt": "2026-09-29T19:04:13.349807Z",
      "expiresAt": "2026-10-29T19:04:13.349807Z",
      "status": "available"
     },
     {
      "grantedAt": "2026-10-07T23:29:37.023363Z",
      "expiresAt": "2026-11-06T23:29:37.023363Z",
      "status": "available"
     }
    ]
   },
   "metadata": {
    "planType": "team",
    "allowed": true,
    "limitReached": false,
    "email": "user@example.com",
    "accountId": "acct-2",
    "meterStates": {
     "chat": {
      "allowed": true,
      "limitReached": false
     }
    },
    "orgId": "acct-2",
    "orgName": "Example"
   }
  }
 ],
 "accountsWithoutUsage": [],
 "disabledCredentials": [
  {
   "id": 21,
   "provider": "openai-codex",
   "type": "oauth",
   "cause": "oauth refresh failed: 401",
   "email": "user@example.com",
   "accountId": "acct-3",
   "orgId": "acct-3",
   "orgName": "Example",
   "disabledAtMs": @T-2600000@
  }
 ],
 "capacity": {
  "openai-codex": [
   {
    "window": "5h",
    "durationMs": 18000000,
    "meter": "chat",
    "accounts": 2,
    "usedAccounts": @X5@,
    "remainingAccounts": 2
   },
   {
    "window": "7d",
    "durationMs": 604800000,
    "meter": "chat",
    "accounts": 2,
    "usedAccounts": @XWK@,
    "remainingAccounts": 2
   }
  ]
 }
}
]],
	history = [[
{
 "generatedAt": @T+0@,
 "sinceMs": @T-604800@,
 "entries": [
  {
   "recordedAt": @T-86303@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 0,
   "status": "ok",
   "resetsAt": @T-71211@
  },
  {
   "recordedAt": @T-86303@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0,
   "status": "ok",
   "resetsAt": @T+515589@
  },
  {
   "recordedAt": @T-86303@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:5h",
   "label": "Claude 5 Hour",
   "windowLabel": "5 Hour",
   "usedFraction": 0.07,
   "status": "ok",
   "resetsAt": @T-77756@
  },
  {
   "recordedAt": @T-86303@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:7d",
   "label": "Claude 7 Day",
   "windowLabel": "7 Day",
   "usedFraction": 0.02,
   "status": "ok",
   "resetsAt": @T+165844@
  },
  {
   "recordedAt": @T-82827@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 1,
   "status": "exhausted",
   "resetsAt": @T-71213@
  },
  {
   "recordedAt": @T-82827@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.16,
   "status": "ok",
   "resetsAt": @T+515587@
  },
  {
   "recordedAt": @T-73214@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 1,
   "status": "exhausted",
   "resetsAt": @T-71213@
  },
  {
   "recordedAt": @T-73214@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.16,
   "status": "ok",
   "resetsAt": @T+515587@
  },
  {
   "recordedAt": @T-73214@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 0.79,
   "status": "ok",
   "resetsAt": @T-71211@
  },
  {
   "recordedAt": @T-73214@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.12,
   "status": "ok",
   "resetsAt": @T+515589@
  },
  {
   "recordedAt": @T-73214@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:5h",
   "label": "Claude 5 Hour",
   "windowLabel": "5 Hour",
   "usedFraction": 0.06,
   "status": "ok",
   "resetsAt": @T-59756@
  },
  {
   "recordedAt": @T-73214@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:7d",
   "label": "Claude 7 Day",
   "windowLabel": "7 Day",
   "usedFraction": 0.06,
   "status": "ok",
   "resetsAt": @T+165844@
  },
  {
   "recordedAt": @T-61448@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 0,
   "status": "ok",
   "resetsAt": @T-50293@
  },
  {
   "recordedAt": @T-61448@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.16,
   "status": "ok",
   "resetsAt": @T+515587@
  },
  {
   "recordedAt": @T-61299@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 0,
   "status": "ok",
   "resetsAt": @T-50290@
  },
  {
   "recordedAt": @T-61299@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.12,
   "status": "ok",
   "resetsAt": @T+515589@
  },
  {
   "recordedAt": @T-61298@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:5h",
   "label": "Claude 5 Hour",
   "windowLabel": "5 Hour",
   "usedFraction": 0.09,
   "status": "ok",
   "resetsAt": @T-59756@
  },
  {
   "recordedAt": @T-61298@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:7d",
   "label": "Claude 7 Day",
   "windowLabel": "7 Day",
   "usedFraction": 0.06,
   "status": "ok",
   "resetsAt": @T+165844@
  },
  {
   "recordedAt": @T-50391@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 0,
   "status": "ok",
   "resetsAt": @T-50290@
  },
  {
   "recordedAt": @T-50391@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.12,
   "status": "ok",
   "resetsAt": @T+515589@
  },
  {
   "recordedAt": @T-50333@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 0,
   "status": "ok",
   "resetsAt": @T-50293@
  },
  {
   "recordedAt": @T-50333@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.16,
   "status": "ok",
   "resetsAt": @T+515587@
  },
  {
   "recordedAt": @T-50333@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:5h",
   "label": "Claude 5 Hour",
   "windowLabel": "5 Hour",
   "usedFraction": 0.23,
   "status": "ok",
   "resetsAt": @T-41756@
  },
  {
   "recordedAt": @T-50333@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:7d",
   "label": "Claude 7 Day",
   "windowLabel": "7 Day",
   "usedFraction": 0.1,
   "status": "ok",
   "resetsAt": @T+165844@
  },
  {
   "recordedAt": @T-43128@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 0,
   "status": "ok",
   "resetsAt": @T-32230@
  },
  {
   "recordedAt": @T-43128@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.16,
   "status": "ok",
   "resetsAt": @T+515587@
  },
  {
   "recordedAt": @T-43128@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:5h",
   "label": "Claude 5 Hour",
   "windowLabel": "5 Hour",
   "usedFraction": 0.34,
   "status": "ok",
   "resetsAt": @T-41756@
  },
  {
   "recordedAt": @T-43128@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:7d",
   "label": "Claude 7 Day",
   "windowLabel": "7 Day",
   "usedFraction": 0.12,
   "status": "ok",
   "resetsAt": @T+165844@
  },
  {
   "recordedAt": @T-39526@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 0,
   "status": "ok",
   "resetsAt": @T-32228@
  },
  {
   "recordedAt": @T-39526@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.12,
   "status": "ok",
   "resetsAt": @T+515589@
  },
  {
   "recordedAt": @T-17825@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 0.05,
   "status": "ok",
   "resetsAt": @T-2880@
  },
  {
   "recordedAt": @T-17825@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.13,
   "status": "ok",
   "resetsAt": @T+515589@
  },
  {
   "recordedAt": @T-17825@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:5h",
   "label": "Claude 5 Hour",
   "windowLabel": "5 Hour",
   "usedFraction": 0.15,
   "status": "ok",
   "resetsAt": @T-3356@
  },
  {
   "recordedAt": @T-17825@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:7d",
   "label": "Claude 7 Day",
   "windowLabel": "7 Day",
   "usedFraction": 0.14,
   "status": "ok",
   "resetsAt": @T+165844@
  },
  {
   "recordedAt": @T-17772@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 0.03,
   "status": "ok",
   "resetsAt": @T-5956@
  },
  {
   "recordedAt": @T-17772@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.16,
   "status": "ok",
   "resetsAt": @T+515587@
  },
  {
   "recordedAt": @T-10763@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 0.05,
   "status": "ok",
   "resetsAt": @T-2879@
  },
  {
   "recordedAt": @T-10763@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-5",
   "email": "user@example.com",
   "accountId": "acct-5",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.13,
   "status": "ok",
   "resetsAt": @T+515589@
  },
  {
   "recordedAt": @T-10763@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:primary",
   "label": "5 hours",
   "windowLabel": "5 hours",
   "usedFraction": 0.03,
   "status": "ok",
   "resetsAt": @T-5956@
  },
  {
   "recordedAt": @T-10763@,
   "provider": "openai-codex",
   "accountKey": "oauth|account:acct-6",
   "email": "user@example.com",
   "accountId": "acct-6",
   "limitId": "openai-codex:secondary",
   "label": "7 days",
   "windowLabel": "7 days",
   "usedFraction": 0.16,
   "status": "ok",
   "resetsAt": @T+515587@
  },
  {
   "recordedAt": @T-10717@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:5h",
   "label": "Claude 5 Hour",
   "windowLabel": "5 Hour",
   "usedFraction": 0.37,
   "status": "ok",
   "resetsAt": @T-3356@
  },
  {
   "recordedAt": @T-10717@,
   "provider": "anthropic",
   "accountKey": "oauth|account:acct-4",
   "email": "user@example.com",
   "accountId": "acct-4",
   "limitId": "anthropic:7d",
   "label": "Claude 7 Day",
   "windowLabel": "7 Day",
   "usedFraction": 0.18,
   "status": "ok",
   "resetsAt": @T+165844@
  }
 ]
}
]],
	stats = [[
{
 "overall": {
  "totalRequests": 3585,
  "totalCost": 305.48,
  "totalInputTokens": 21000000,
  "totalOutputTokens": 900000
 },
 "byModel": [],
 "byFolder": [],
 "byAgentType": [],
 "timeSeries": [
  {
   "timestamp": @T-90000@,
   "requests": 900,
   "errors": 0,
   "tokens": 9000000,
   "cost": 80.0
  },
  {
   "timestamp": @T+0@,
   "requests": 120,
   "errors": 1,
   "tokens": 1500000,
   "cost": 12.4
  }
 ],
 "modelSeries": [],
 "modelPerformanceSeries": [],
 "costSeries": []
}
]],
	release = [[
{
 "url": "https://api.github.com/repos/joaodutra88/tern-omp-usage/releases/421987334",
 "html_url": "https://github.com/joaodutra88/tern-omp-usage/releases/tag/v@VERSION@",
 "id": 421987334,
 "tag_name": "v@VERSION@",
 "target_commitish": "a4ef2807a9fabc2a40463b7ef7d9cec4f5326984",
 "name": "v@VERSION@",
 "draft": false,
 "prerelease": false,
 "created_at": "2026-10-23T15:10:11Z",
 "published_at": "2026-10-23T15:10:30Z",
 "assets": [],
 "tarball_url": "https://api.github.com/repos/joaodutra88/tern-omp-usage/tarball/v0.4.0",
 "zipball_url": "https://api.github.com/repos/joaodutra88/tern-omp-usage/zipball/v0.4.0",
 "body": "- Something new.\n- A fix."
}
]],
}
