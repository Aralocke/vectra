Vectra
======

The 'Vectra' project. culminating in over 5 years of work and more than 10,000 lines of code, the 
Vectra project was an IRC Stats bot based around the MMORPG game 'RuneScape'.

AT it's height, Vectra served over 10,000 users primarily on the IRC network SwiftIRC. The project 
ended in 2011 due to financial issues, however I hope the software that was in development at the 
time can be a viable source of education for future IRC bot developers.

The Future
===========

In the end the downfall of Vectra turned out to be it's scalability issues vs. maintaining an acceptable
cost margin for those of us supporting it. After Vectra closed I started working on the solution in hopes
of one day bringing the project alive in a different medium.

My solution was to abstract the protocol layer and make the "bot" just a simple connection which handles
events. This abstraction led to what eventually became the ProtocolBot Framework 
(https://github.com/Arconiaprime/protocolbot) and it's development cycle which is slowly but surely happening
in my freetime.