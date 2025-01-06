# Powershells
Various Powershells that were useful at the time.  Most scripts have more relevant information commented out in the code.  Please use at your leisure!

### DeleteByIssuerThumbprint.ps1
Created to remove **host** certificates by testing each for a thumbprint from a specific **issuer**.  Is suitable regardless of if issuer is a subCA or CA.  Given that the 'BuildChain' method will also include the child certificate too, it would be suitable for removing a specific client certificate also.  Target store can be adjusted if necessary, currently fixed to computer store.  Script has a comment disabling the final delete instruction.  If you can find the comment and take it out, you are qualified to use this script.


### DISCLAIMER!
I have no reason to think any of these won't work.  That said, if you use these, I cannot be responsible, which would include anything from misuse, or other unpleasant outcomes.  This code is here for educational purposes, and I'd encourage you to read and understand the code before using it.
