// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
import { createInput, insertFirst } from './utilities'

const comments = (function() {
  function handleEvent(_e = null) {
    scrollCommentIntoView()
    const commentTextArea = document.getElementById('comment_text')
    if (commentTextArea) initializeSubmitButton(commentTextArea)
    let manageEventListeners = commentTextArea ? replyForm : loginReminder
    document.querySelectorAll('.reply').forEach(manageEventListeners)
  }

  // touches DOM
  function scrollCommentIntoView() {
    let comment
    if (!gon ||
        !gon.comment_id ||
        !(comment = document.getElementById(gon.comment_id))
      ) return
    comment.scrollIntoView()
    comment.parentNode.classList.add('new')
  }


  // touches DOM
  function initializeSubmitButton(commentTextArea) {
    toggleSubmitButton({ target: commentTextArea })
    commentTextArea.addEventListener('input', toggleSubmitButton)
  }

  // event listener
  function toggleSubmitButton(event) {
    const input = event.target
    input.closest('.comment-form')
        .querySelector('.btn-primary')
        .classList[input.value.trim() ? 'remove' : 'add']('hide')
  }


  // touches DOM
  function replyForm(reply) {
    reply.addEventListener('click', function(event) {
      event.preventDefault()
      const parentID = reply.dataset.commentId
      const parent = document.getElementById(parentID)
      const formContainer = document.querySelector('.commenting.top-level')
                                    .cloneNode(true)
      formContainer.className =
        formContainer.className.replace('top-level', 'reply')
      const form = formContainer.querySelector('.comment-form')
      insertFirst(form, parentageInput(parentID))
      form.querySelector('.buttons').appendChild(cancelButton({}))
      const commentTextArea = form.querySelector('#comment_text')
      commentTextArea.value = ""
      commentTextArea.id = ""
      const buttons = form.querySelector('.btn-primary')
      buttons.classList.add('hide')
      commentTextArea.addEventListener('input', toggleSubmitButton)
      parent.appendChild(formContainer)
      reply.classList.add('hide')
    })
  }

  // touches DOM
  function loginReminder(reply) {
    reply.addEventListener('click', function(event) {
      event.preventDefault()
      const parentID = reply.dataset.commentId
      const parent = document.getElementById(parentID)
      const formContainer = document.querySelector('.members-only')
                                    .cloneNode(true)
      formContainer.classList.add('reply')
      const redirectInput = formContainer.querySelector('input[name="origin"]')
      redirectInput.setAttribute('value', window.location.pathname)
      formContainer.querySelector('.nav')
                   .appendChild(cancelButton({ classes: ['link'] }))
      parent.appendChild(formContainer)
      reply.classList.add('hide')
    })
  }

  // event listener
  function cancelNewComment(event) {
    const target = event.target
    target.removeEventListener('click', cancelNewComment)
    const formContainer = target.closest('.reply')
    const comment_draft = formContainer.querySelector('.comment-draft')
    if (comment_draft) {
      comment_draft.removeEventListener('input', toggleSubmitButton)
    }
    const commentingBlock = formContainer.parentNode
    commentingBlock.removeChild(formContainer)
    commentingBlock.querySelector('.reply').classList.remove('hide')
  }

  // pure
  const parentageInput = parentID => createInput({ attributes:
      { type: 'hidden', name: 'comment[parent_id]', value: parentID }
  })

  // pure
  function cancelButton({ classes = [] }) {
    return createInput({
      attributes: { value: 'Cancel', type: 'button' },
      classes: ['btn', 'btn-secondary'].concat(classes),
      eventListeners: { click: cancelNewComment }
    })
  }

  return { handleEvent }
})()

// main
document.addEventListener('DOMContentLoaded', comments)
