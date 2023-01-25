USING: extension.mop tools.test kernel sequences ;

IN: extension.mop.tests

{ H{
    { name: "direct-superclasses" }
    { type: V{ sequence sequence } }
  }
} [ { "direct-superclasses" type: sequence type: sequence } canonicalize-direct-slot ] unit-test
