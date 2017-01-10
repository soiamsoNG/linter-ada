'use babel'

module.exports =

  config:
    StyleCheckSwitch:
      type: 'boolean'
      default: true
    StyleCheckParametersList:
      type: 'string'
      default: '3abcefhiklmnprst'

  activate: ->
    require('atom-package-deps').install 'linter-ada'

  provideLinter: ->
    LinterAda = require('./linter-ada')
    @provider = new LinterAda()
    {
    name: 'LinterAda'
    grammarScopes: ['source.ada','source.ads']
    scope: 'project'
    lint: @provider.lint
    lintOnFly: false
    }
