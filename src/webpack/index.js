import 'normalize.css'
import './assets/gravity-toy.css'

import TouchEmulator from 'hammer-touchemulator'
import addEventListener from 'add-event-listener'
import React from 'react'
import { render } from 'react-dom'

import GravityToy from './components/gravity-toy'

/******************************************************************************/
// Setup Touch
/******************************************************************************/

TouchEmulator()

TouchEmulator.template = () => {} // Do not visualize touch

/******************************************************************************/
// Execute
/******************************************************************************/

addEventListener(window, 'load', () => {

  const mainTag = document.getElementById('gravity-toy')

  render(<GravityToy />, mainTag)
})
