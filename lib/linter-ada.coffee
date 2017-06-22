fs = require 'fs'
path = require 'path'
atom_linter = require 'atom-linter'

module.exports = class LinterAda
  constructor: () ->
  lint: (textEditor) ->
    editingFile = textEditor.getPath()
    cwd = path.dirname editingFile
    efName = path.basename editingFile

    regex = '(?<file>.+):(?<line>\\d+):(?<col>\\d+):\\s(?<message>.+)'
    styleregex = '\\(style\\).*'
    warningregex = 'warning.*'
    scs = atom.config.get('linter-ada.StyleCheckSwitch')
    scp = atom.config.get('linter-ada.StyleCheckParametersList')
    wm = atom.config.get('linter-ada.WarningMode')

    # Find out the projectpath base one current editingFile
    [projectPath, relativePath] = atom.project.relativizePath(editingFile)

    gprregex = '.+\\.gpr'
    if projectPath == null
      gprfiles = []
    else
      gprfiles = fs.readdirSync(projectPath).filter (x) -> x.match(gprregex)

    #Check if need to do style check
    if scs == true
      parList = ["-c","-f","-F","-eS",
                  "-gnatef","-gnatc","-gnatw#{wm}","-gnaty#{scp}"]
    else
      parList = ["-c","-f","-F","-eS","-gnatef","-gnatw#{wm}","-gnatc"]

    #Check if we have .gpr file in the project (atom's project idea) path
    #if we have .gpr then use the first one
    if gprfiles.length != 0
      firstGPR = gprfiles[0]
      atom.notifications.addSuccess("LinterAda: Using #{firstGPR} for lint")
      parList = ["-P",firstGPR].concat parList
      parList = parList.concat efName
      gnatMakeRunPath = projectPath
    else
      atom.notifications.addInfo "LinterAda: No GPR found in Atom's \
        Project root will put obj file in current directory"
      #Need to use the fullpath, so gnatmake wull givback a fullpath
      parList = parList.concat editingFile
      gnatMakeRunPath = cwd

    atom_linter.exec("gprbuild", parList, {cwd:gnatMakeRunPath, stream: 'both'})
    .then (output) ->
      {stdout, stderr, exitCode} = output
      warnings = atom_linter.parse(stderr,regex).map((parsed) ->
        message = {}
        line = parsed.range[0][0]
        col = parsed.range[0][1]
        if parsed.text.match(styleregex)
          message.severity = 'warning'
        else if parsed.text.match(warningregex)
          message.severity = 'warning'
        else
          message.severity = 'error'
        message.excerpt = parsed.text
        message.location = {
          file: parsed.filePath,
          position: [[line,col],[line,col]]
        }
        return message
        )
      return warnings
