this is my first block program                                  This just has a few simple definitons to play with              # Info                                                          - page 0 is for text                                            - page 1 and above is for code                                  - --> is to continue to load pages                              - use blocked.fb 0 list ( to access a good editor )               + use 1 load to load the editor                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               \ First Program                                                 : foo ( u -- u ) dup * ;                                        : hello ." world" ;                                             : STAR    [CHAR] * EMIT ;                                       : STARS   0 DO  STAR  LOOP ;                                    : MARGIN  CR 30 SPACES ;                                        : BLIP    MARGIN STAR ;                                         : BAR     MARGIN 5 STARS ;                                      : F       BAR BLIP BAR BLIP BLIP CR ;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           