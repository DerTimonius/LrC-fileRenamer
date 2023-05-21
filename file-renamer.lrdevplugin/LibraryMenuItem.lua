local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrColor = import 'LrColor'
local LrPrefs = import 'LrPrefs'
local LrLogger = import "LrLogger"

LibraryItem = {}

local logger = LrLogger("libraryLogger")
logger:enable("print")

function LibraryItem.outToLog(message)
  logger:trace(message)
end

function LibraryItem.showCustomDialogWithObserver()
  LrFunctionContext.callWithContext("showCustomDialogWithObserver", function (context)
    local props = LrBinding.makePropertyTable(context)
    props.myObservedString = "This is a string"

    local f = LrView.osFactory()
    local showValue_st = f:static_text{
      title = props.myObservedString,
      text_color = LrColor(1, 0, 0)
    }
    local updateField = f:edit_field {
      value = "Enter some text",
      immediate = true
    }

    local myCalledFunction = function()
      showValue_st.title = updateField.value
      showValue_st.text_color = LrColor(1, 0, 0)
    end

    props:addObserver("myObservedString", myCalledFunction)

    local c = f:column {
      f:row {
        fill_horizontal = 1,
        f:static_text {
          alignment = "right",
          width = LrView.share "label_width",
          title = "Bound value: "
        },
        showValue_st,
      },
      f:row {
        f:static_text{
          alignment = "right",
          width = LrView.share "label_width",
          title = "New value: "
        },
        updateField,
        f:push_button {
          title = "Update",
          action = function()
            showValue_st.text_color = LrColor(0, 0, 0)
            props.myObservedString = updateField.value
          end
        },
      },
    }

    local result = LrDialogs.presentModalDialog{
      title = "Custom Observe",
      contents = c
    }

  end)
end

function LibraryItem.showSettingsDialog()
  LrFunctionContext.callWithContext("showSettingsDialog", function (context)
    local props = LrBinding.makePropertyTable(context)

    local pluginPrefs = LrPrefs.prefsForPlugin("dertimonius.filerenamer")
    pluginPrefs.preferredSettings = {}

    local bind = LrView.bind
    local f = LrView.osFactory()

    local currentString = f:static_text {
      title = "Example: DSC_0001.jpg"
    }

    local checkboxes = {
      {id = "iso", title = "ISO"},
      {id = "shutter", title = "Shutter speed"},
      {id = "aperture", title = "Aperture"},
      {id = "model", title = "Camera model"},
      {id = "make", title = "Camera manufacturer"},
      {id = "focalLength", title = "Focal length"},
      {id = "lens", title = "Lens"},
    }


    local function displayCheckboxes()
      local checkboxViews = {}
      for _, checkbox in ipairs(checkboxes) do
        local checkboxView = f:checkbox {
          title = checkbox.title,
          value = bind {
            keys = {"preferredSettings", checkbox.id},
            bind_to_object = pluginPrefs,
            transform = function(value)
              return value or false
            end
          },
        }
        table.insert(checkboxViews, checkboxView)
      end
      return checkboxViews
    end

    local function saveCheckboxValues()
      for _, checkbox in ipairs(checkboxViews) do
        if checkbox.value then
          pluginPrefs.preferredSettings[checkbox.id] = checkbox.value
        end
      end
    end

    local contents = f:column {
      bind_to_object = pluginPrefs,
      fill_horizontal = 1,
      spacing = f:control_spacing(),
      f:group_box {
        title = "Available metadata",
        fill_horizontal = 1,
        spacing = f:control_spacing(),
        unpack(displayCheckboxes())
      },
      f:static_text {
        currentString
      },
      f:push_button {
        title = "Save",
        action = function()
          saveCheckboxValues()
        end
      }
    }

    local result = LrDialogs.presentModalDialog{
      title = "FileRenamer Settings",
      contents = contents,
    }
  end)
end

LibraryItem.showSettingsDialog()
