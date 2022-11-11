! Copyright (C) 2022 mariari.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test misc.padding alien.c-types kernel math ;
IN: misc.padding.tests



{ t } [ char-short heap-size char-short-no-padding heap-size = ] unit-test

{ t } [ list-wasteful heap-size list heap-size > ] unit-test
