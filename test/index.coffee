#!/usr/bin/env coffee

import seed from '../src/index'
import {seed as Xxx} from '../src/index'
import test from 'tape'

test 'seed', (t)=>
  t.equal seed(1,2),3
  t.deepEqual Xxx([1],[2]),[3]
  t.end()
