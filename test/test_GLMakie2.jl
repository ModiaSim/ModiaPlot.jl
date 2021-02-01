module test_GLMakie2

import GLMakie

t = range(0.0, stop=10.0, length=100)

phi  = sin.(t)
phi2 = 0.5 * sin.(t)
w    = cos.(t)
w2   = 0.6 * cos.(t)

LinesLegend(args...) = GLMakie.Legend(args...; margin=[0,0,0,0], padding=[5,5,0,0], rowgap=0, halign=:right, valign=:top, 
                                               linewidth=1, labelsize=10, tellheight=false, tellwidth=false)

GLMakie.set_theme!(fontsize = 12)  

figure1 = GLMakie.Figure(resolution=(900,700))

        figure1[1,1] = GLMakie.Axis(figure1, title = "axis1", xlabel="xaxis1")
        figure1[2,1] = GLMakie.Axis(figure1, title = "axis2", xlabel="xaxis2")
        figure1[1,2] = GLMakie.Axis(figure1, title = "axis3", xlabel="xaxis3")
axis4 = figure1[2,2] = GLMakie.Axis(figure1)
axis4.title  = "axis4"
axis4.xlabel = "xaxis4"

line1 = GLMakie.lines!(figure1[1,1], t, phi , color="blue1")     
line2 = GLMakie.lines!(figure1[2,1], t, phi2, color="red1")
line3 = GLMakie.lines!(figure1[2,1], t, w2  , color=("blue1", 0.3))
line4 = GLMakie.lines!(figure1[1,2], t, w   , color="blue1") 
line5 = GLMakie.lines!(axis4, t, w2  , color="blue1") 

#@show line1.attributes

figure1[1,1] = LinesLegend(figure1, [line1], ["line1"])
figure1[2,1] = LinesLegend(figure1, [line2, line3], ["line2", "line3"])
                 
figure1[0,:] = GLMakie.Label(figure1, "Heading", textsize = 14)
figure1[1,1,GLMakie.TopLeft()] = GLMakie.Label(figure1, "showFigure(1)", textsize=9, color=:blue, halign = :left, padding = (0, 0, 0, -30))


GLMakie.trim!(  figure1.layout)
GLMakie.update!(figure1.scene)
display(figure1)

end