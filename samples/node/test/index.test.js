const test = require('node:test');
const assert = require('node:assert');
const { greet } = require('../src/index');

test('greet returns expected message', () => {
  assert.strictEqual(greet('SecureCI'), 'Hello, SecureCI!');
});
