'use babel'

module.exports =

  config:
    StyleCheckSwitch:
      type: 'boolean'
      default: true
    StyleCheckParametersList:
      type: 'string'
      default: '3abcefhiklmnprst'
    WarningMode:
      type: 'string'
      description: 'This will use by warning mode which set by -gnatw in command line'
      default: 'a'

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
