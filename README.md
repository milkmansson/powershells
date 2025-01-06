# Powershells
Various Powershells that were useful at some time.  Most scripts have more relevant information commented out in the code.  Please use at your leisure!

### DeleteByIssuerThumbprint.ps1
Created to remove **host** certificates by testing each for a thumbprint from a specific **issuer**.  
- Given that the 'BuildChain' method will create an object including host cert, SubCA, and CA certs, it is suitable for removing a cert where the thumbprint is from the host cert, direct parent subCA, a subCA further up a tree, the root CA itself.
- Target store can be adjusted if necessary, currently fixed to **computer** store.
- Script has a comment disabling the final delete instruction - if you can find/remove the comment character, you are qualified to use this script.

### functions.ps1
Various helper functions that I would use often through projects.
- Due to these being created for specific purposes and specific customers/targets, some might need minor bugfixing.

### DISCLAIMER!
I have no reason to think any of these won't work.  That said, if you use these, I cannot be responsible, which would include anything from misuse, or other unpleasant outcomes.  This code is here for educational purposes, and I'd encourage you to read and understand the code before using it.
