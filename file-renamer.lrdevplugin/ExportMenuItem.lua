local LrDialogs = import 'LrDialogs'

ExportItem = {}
function ExportItem.showModalDialog()
  LrDialogs.message("ExportMenuItem Selected", "The settings can be found under Library > Plug-In Extras > FileRenamer Settings", "info")
end

ExportItem.showModalDialog()
