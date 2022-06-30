using Pkg
Pkg.activate(".")
Pkg.add("Vega")
Pkg.add("VegaDatasets")

using Vega
using VegaDatasets
plot = @vgplot(
    height=720,
    width=720,
    padding=5,
    marks=[
        {
            encode={
                update={
                    stroke={
                        value="#ccc"
                    },
                    path={
                        field="path"
                    }
                }
            },
            from={
                data="edges"
            },
            type="path"
        },
        {
            type="symbol",
            from={
                data="arrows"
            },
            encode={
                update={
                    shape={
                        value="triangle-up"
                    },
                    x={
                        field="x"
                    },
                    angle={
                        field="angle"
                    },
                    y={
                        field="y"
                    }
                },
                enter={
                    shape={
                        value="triangle-up"
                    },
                    fill={
                        value="#ccc"
                    },
                    size={
                        value=200
                    },
                    stroke={
                        value="#555"
                    },
                    strokeWidth={
                        value=1
                    }
                }
            }
        },
        {
            encode={
                update={
                    x={
                        field="x"
                    },
                    fill={
                        field="color"
                    },
                    y={
                        field="y"
                    }
                },
                enter={
                    stroke={
                        value="#fff"
                    },
                    size={
                        value=300
                    }
                }
            },
            from={
                data="nodes"
            },
            type="symbol"
        },
        {
            encode={
                update={
                    align={
                        signal="datum.children ? 'right' : 'left'"
                    },
                    x={
                        field="x"
                    },
                    dx={
                        value=12                    
                    },
                    y={
                        field="y"
                    },
                    dy={
                        value=-10                    
                    },
                },
                enter={
                    fontSize={
                        value=15
                    },
                    text={
                        field="name"
                    },
                    baseline={
                        value="middle"
                    }
                }
            },
            from={
                data="nodes"
            },
            type="text"
        }
    ],
    data=[
        #ROSSO: #f00
        #VERDE: #0f0
        #BLU: #00f
        {
            name="nodes",
            values= [
                {id= 1, name="spaceindex", x=  360, y=360, color="#f00"},
                {id= 2, name="boundingbox", x=  360, y=200, color="#00f"},
                {id= 3, name="coordintervals", x=  360, y=520, color="#00f"},
                {id= 4, name="boxcovering", x=  500, y=360, color="#00f"},
                {id= 5, name="fragmentlines", x=  150, y=320, color="#f00"},
                {id= 6, name="pointInPolygonClassification", x=  250, y=240, color="#f00"},
                {id= 7, name="setTile", x=  110, y=240, color="#00f"},
                {id= 8, name="crossingTest", x=  250, y=170, color="#00f"},
                {id= 9, name="intersection", x=  310, y=380, color="#00f"},
                {id= 10, name="linefragments", x=  150, y=380, color="#00f"},
                {id= 11, name="fraglines", x=  350, y=320, color="#00f"},
                {id= 12, name="congruence", x=  330, y=260, color="#00f"},
                {id= 13, name="input_collection", x=  110, y=200, color="#00f"},

               ],
            transform= [
                {
                  type= "formula",
                  expr= "atan2(datum.y, datum.x)",
                  as= "angle"
                },
                {
                  type= "formula",
                  expr= "sqrt(datum.y * datum.y + datum.x * datum.x)",
                  as= "radius"
                }
              ]
        },
        {
              name= "edges",
              values= [
                {s=1, t=2},
                {s=1, t=3},
                {s=1, t=4},
                {s=5, t=1},
                {s=5, t=10},
                {s=6, t=7},
                {s=6, t=8},
                {s=10, t=9},
                {s=5, t=10},
                {s=5, t=12},
                {s=11, t=5}
                ],
              transform= [
                {
                  type= "lookup",
                  from= "nodes",
                  key= "id",
                  fields= ["s", "t"],
                  as= ["source", "target"]
                },
                {
                  type= "linkpath",
                  shape= "line"
                }
            ],
        },
        {
            name="arrows",
            values=[
                {id=1, x=360, y=215, angle=0},
                {id=2, x=150, y=365, angle=180},
                {id=3, x=310, y=268, angle=190},
                {id=4, x=290, y=380, angle=212},
                {id=5, x=340, y=358, angle=220},
                {id=6, x=480, y=362, angle=212},
                {id=7, x=250, y=186, angle=0},
                {id=8, x=127, y=240, angle=270},
                {id=9, x=360, y=504, angle=180},
                {id=10, x=170, y=318, angle=36},
                
            ]
        }
    ]
)

#plot |> save("GraficoFunzionaleRefactor.pdf")
