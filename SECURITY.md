# Security

The plugin only runs `omp` and reads its JSON output. It makes no network requests, reads no credentials and writes nothing to disk, so most problems will be plain bugs, not security issues.

If you find something that could leak account data (emails, account ids, tokens) or run code it shouldn't, please don't open a public issue. Report it privately from the repository's **Security** tab, using **Report a vulnerability**.

Only the latest release is supported.
