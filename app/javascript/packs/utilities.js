function createInput({ attributes = {}, classes = [], eventListeners = {} }) {
  const input = document.createElement('input')
  setAttributes(attributes, input)
  input.classList.add(...classes)
  addEventListeners(eventListeners, input)
  return input
}

function insertFirst(parent, newChild) {
  parent.insertBefore(newChild, parent.firstChild)
}

function setAttributes(attributes, element) {
  for (const attribute in attributes) {
    element.setAttribute(attribute, attributes[attribute])
  }
}

function addEventListeners(listeners, element) {
  for (const trigger in listeners) {
    element.addEventListener(trigger, listeners[trigger])
  }
}

export { createInput, insertFirst }
