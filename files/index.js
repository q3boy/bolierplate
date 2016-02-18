try {
  path = require.resolve('./dist/lib/index')
} catch (e) {
  if (require.extensions['.coffee'] === undefined) {
   require('coffee-script/register')
  }
  path = './lib/index'
}
module.exports = require(path)