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
        {
            name="nodes",
            values= [
                {id= 1, name="spaceindex", x=  360, y=360, color="#f00"},
                {id= 2, name="boundingbox", x=  360, y=200, color="#f00"},
                {id= 3, name="coordintervals", x=  360, y=520, color="#f00"},
                {id= 4, name="boxcovering", x=  500, y=360, color="#f00"},
                {id= 5, name="fragmentlines", x=  150, y=290, color="#00f"},
                {id= 6, name="setTile", x=  30, y=590, color="#00f"},
                {id= 7, name="linefragments", x=  150, y=220, color="#00f"},
                {id= 8, name="hcat", x=  470, y=160, color="#00f"},
                {id= 9, name="intersection", x=  150, y=160, color="#00f"},
                {id= 10, name="congruence", x=  30, y=290, color="#00f"},
                {id= 11, name="intersect", x=  580, y=250, color="#00f"},
                {id= 12, name="fraglines", x=  30, y=380, color="#00f"},
                {id= 13, name="pointInPolygonClassification", x=  130, y=590, color="#00f"},
                {id= 14, name="enumerate", x=  430, y=440, color="#00f"},
                {id= 15, name="crossingTest", x=  130, y=510, color="#00f"},
                {id= 16, name="haskey", x=  430, y=580, color="#00f"},
                {id= 17, name="input_collection", x=  30, y=480, color="#00f"},
                {id= 18, name="mapslices", x=  300, y=140, color="#00f"},
                {id= 19, name="min", x=  230, y=180, color="#00f"},
                {id= 20, name="max", x=  250, y=240, color="#00f"},
                {id= 21, name="addIntersection", x=  510, y=500, color="#0ff"},
                {id= 22, name="createIntervalTree", x=  140, y=345, color="#0ff"},
                {id= 23, name="removeIntersection", x=  130, y=440, color="#0ff"},
                {id= 24, name="Utility_function_pointInPolygon_1-15", x=  130, y=680, color="#0ff"},

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
                {s=5, t=7},
                {s=1, t=8},
                {s=7, t=9},
                {s=5, t=10},
                {s=1, t=11},
                {s=12, t=5},
                {s=13, t=6},
                {s=1, t=3},
                {s=1, t=4},
                {s=1, t=22},
                {s=1, t=23},
                {s=2, t=18},
                {s=2, t=19},
                {s=2, t=20},
                {s=3, t=14},
                {s=3, t=16},
                {s=13, t=15},
                {s=4, t=11},
                {s=13, t=24},
                {s=4, t=14},
                {s=4, t=21},
                {s=5, t=1},
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
                {id=3, x=463, y=172, angle=25},
                {id=6, x=567, y=255, angle=60},
                {id=9, x=485, y=360, angle=90},
                {id=10, x=360, y=505, angle=180},
                {id=12, x=346, y=356, angle=113},
                {id=13, x=310, y=150, angle=-40},
                {id=14, x=245, y=183, angle=-80},
                {id=15, x=263, y=234, angle=-115},
                {id=16, x=573, y=261, angle=30},
                {id=20, x=440, y=430, angle=-135},
                {id=21, x=420, y=450, angle=42},
                {id=22, x=419, y=569, angle=135},
                {id=24, x=510, y=485, angle=178},
                {id=25, x=155, y=346, angle=-87},
                {id=26, x=145, y=436, angle=-118},                
                {id=27, x=150, y=236, angle=0},
                {id=28, x=150, y=176, angle=0},
                {id=29, x=45, y=290, angle=-90},
                {id=30, x=138, y=299, angle=45},
                {id=31, x=45, y=590, angle=-90},
                {id=31, x=130, y=527, angle=0},
                {id=32, x=130, y=662, angle=180},
            ]
        }
    ]
)