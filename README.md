<p align="center">
  <img src="https://santoku.dev/logo-santoku-sqlite-migrate.png" height="64" alt="santoku-sqlite-migrate">
</p>

# santoku-sqlite-migrate

Versioned, idempotent SQL migrations for a santoku-sqlite database handle. One callable
module: give it a handle and a table of named migrations, and it applies the ones that
have not run yet, in version order, forward only, inside a single transaction.

## Documentation

Runnable examples and the full API:
[santoku.dev](https://santoku.dev/#santoku-sqlite-migrate).

For agents and LLM tooling: [llms.txt](https://santoku.dev/llms.txt) for the index,
[llms-full.txt](https://santoku.dev/llms-full.txt) for every documented example.

## License

MIT, see [LICENSE](LICENSE).

