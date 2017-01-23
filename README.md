<!--[![Build Status](https://travis-ci.org/aamini/TimeToContact.jl.svg?branch=master)](https://travis-ci.org/aamini/TimeToContact.jl)

[![Coverage Status](https://coveralls.io/repos/aamini/TimeToContact.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/aamini/TimeToContact.jl?branch=master)

[![codecov.io](http://codecov.io/github/aamini/TimeToContact.jl/coverage.svg?branch=master)](http://codecov.io/github/aamini/TimeToContact.jl?branch=master)
-->

# TimeToContact.jl
## Time to Contact Compuation in Julia
Tags: Mobile Computing, Embedded Devices, Machine Vision, Accelerated Convolutions

Link: https://arxiv.org/abs/1612.08825

## Overview
<center>![alt text](anim.gif "Logo Title Text 1")</center>

Imagine an autonomous vehicle, with a camera mounted on its front, approaching a wall. The time to contact (TTC) is defined as the amount of time that would elapse before the optical center reaches the surface being viewed. This problem can intuitively be thought of as: **how much time will pass before the car collides with the wall?** On the other hand, the focus of expansion (FOE) will determine the precise location on the image plane that the camera is approaching (i.e., **the point on the wall that would ultimately collide first**). TTC and FOE solutions are critical for many robotic systems since they provide a rough safety control capability, based on continuously avoiding collision with objects around it.

TimeToContact.jl provides an interface for computing the time to contact to a single focus of exapansion given only two consecutive input images. 


### Citation:
Paper: [Accelerated Convolutions for Efficient Multi-Scale Time to Contact Computation in Julia](https://arxiv.org/abs/1612.08825) <br>
https://arxiv.org/abs/1612.08825
> Amini, Alexander, Berthold Horn, and Alan Edelman. "Accelerated Convolutions for Efficient Multi-Scale Time to Contact Computation in Julia." arXiv preprint arXiv:1612.08825 (2016).<br>

#### Bibtex: 
> @article{amini2016accelerated, <br>
>    title={Accelerated Convolutions for Efficient Multi-Scale Time to Contact Computation in Julia}, <br>
>    author={Amini, Alexander and Horn, Berthold and Edelman, Alan}, <br>
> journal={arXiv preprint arXiv:1612.08825}, <br>
> year={2016} <br>
> }
