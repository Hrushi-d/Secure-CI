function greet(name) {
  return `Hello, ${name}!`;
}

if (require.main === module) {
  console.log(greet('SecureCI'));
}

module.exports = { greet };
