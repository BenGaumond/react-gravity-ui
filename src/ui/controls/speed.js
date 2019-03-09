import React from 'react'
import { KeyButton } from '../common'

/******************************************************************************/
// Main Component
/******************************************************************************/

const Speed = ({ reverse, gravity, ...props }) =>

  <KeyButton
    {...props}
    down={e => gravity.incrementTargetSpeed(reverse)}
    keys={reverse ? 'j' : 'l'}
  >
    { reverse ? '◀' : '▶' }
  </KeyButton>

/******************************************************************************/
// Defaults
/******************************************************************************/

Speed.defaultProps = {
  $size: 1
}

/******************************************************************************/
// Exports
/******************************************************************************/

export default Speed
