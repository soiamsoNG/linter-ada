path = require 'path'
atom_linter = require 'atom-linter'

module.exports = class LinterAda
  constructor: () ->
  lint: (textEditor) ->
    editingFile = textEditor.getPath()
    cwd = path.dirname editingFile
    regex = '(?<file>.+):(?<line>\\d+):(?<col>\\d+):\\s(?<message>.+)'
    styleregex = '\\(style\\).*'
    scs = atom.config.get('linter-ada.StyleCheckSwitch')
    scp = atom.config.get('linter-ada.StyleCheckParametersList')
    if scs == true
      parList = ["-f","-gnatef","-gnatc","-gnaty#{scp}",editingFile]
    else
      parList = ["-f","-gnatef","-gnatc",editingFile]

    atom_linter.exec("gnatmake", parList, {cwd: cwd, stream: 'both'})
    .then (output) ->
      {stdout, stderr, exitCode} = output
      warnings = atom_linter.parse(stderr,regex).map((parsed) ->
        message = Object.assign({},parsed)
        line = message.range[0][0]
        col = message.range[0][1]
        message.range = [[line,col],[line,col]]
        if message.text.match(styleregex)
          message.type = 'Warning'
        else
          message.type = 'Error'
        return message
        )
      return warnings
