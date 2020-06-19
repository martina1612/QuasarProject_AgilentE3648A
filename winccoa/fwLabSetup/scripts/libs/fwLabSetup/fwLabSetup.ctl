//#uses "fwGeneral/fwException.ctl"


/**@file

@par Creation Date
	12/06/20

@par Modification History

@par Constraints

@author
	Martina Ressegotti
*/

//@{

// +++++ CONFIGS +++++

//===========================================================================
/**Goes through the device dp name and to returns the full hierarchy above
it with device names and positions.

@par Constraints
	None

@par Usage
	Public

@par PVSS managers
	VISION, CTRL

@param deviceDpName			dp name of the device (e.g. CAEN/crate003/board07/channel005)
@param deviceHierarchy		structure containing the hierarchy from the given device going to its parent, grandparent, ect.
							Each row in the dyn_dyn_string has the following structure:
							<ol>
								<li> device dp name
								<li> device position as string (keeping trailing 0s)
								<li> device position as int
							</ol>
							So for example, deviceHierarchy[3][1] will contain the device dp name of the grandparent.
@param exceptionInfo		details of any exceptions
*/
fwLabSetup_getHierarchy(string deviceDpName, dyn_dyn_string &deviceHierarchy, dyn_string &exceptionInfo) {
  if (strlen(deviceDpName) == 0) {
    fwException_raise(exceptionInfo, "ERROR", "Device DP name is blank", "");
  }

  deviceHierarchy = makeDynString(makeDynString());  //reset deviceHierarchy to empty

  dyn_string   hierarchyStr;
  dyn_int      hierarchyInt;
  dyn_string   hierarchyDp;

  string sDpName = dpSubStr(deviceDpName, DPSUB_DP_EL); //strip off system name
  string syst_name = dpSubStr(deviceDpName, DPSUB_SYS);
  int last = strlen(sDpName);

  for (int pos=0; pos<last; pos++)
  {
    string digit = substr(sDpName, pos, 1);
    string temp = "";
    if (patternMatch( "[0123456789]", digit) )
    {
    temp = temp+digit;
    if (pos<last)
      {
      for (int pos2=pos+1; pos2<=last; pos2++)
        {
        pos=pos2;
        string digit = substr(sDpName, pos, 1);
        if ( patternMatch( "[0123456789]", digit) )
          {
          temp = temp+digit;
          }
        else
          break;
        }
      }
    if (pos>2)
      {
      // don't consider dpelements .v0 and .i0
      if (  substr(sDpName, pos-3, 3) != ".v0" && substr(sDpName, pos-3, 3) != ".i0" )
       {
       dynAppend(hierarchyStr, temp);
       dynAppend(hierarchyDp, syst_name+substr(sDpName, 0, pos));
       }
      }
    }

  }

  dyn_string copyStr = hierarchyStr;
  dyn_string copyDp = hierarchyDp;

  //invert the string
  int el=1;
  if ( dynlen(copyStr) == dynlen(copyDp) && dynlen(copyStr) == dynlen(hierarchyStr) && dynlen(copyStr) == dynlen(hierarchyDp) )
    {
    for ( int elCopy = dynlen(copyStr); elCopy > 0; elCopy-- )
      {
      hierarchyStr[el] = copyStr[elCopy];
      hierarchyDp[el]  = copyDp[elCopy];
      el++;
      }
    }
  else
    {
    fwException_raise(exceptionInfo, "ERROR", "Could not determine device hierarchy", "");
    }

  hierarchyInt = hierarchyStr;


  for (int i=1; i<=dynlen(hierarchyStr);i++)
  {
    deviceHierarchy[i][1] = hierarchyDp[i];
    deviceHierarchy[i][2] = hierarchyStr[i];
    deviceHierarchy[i][3] = hierarchyInt[i];
  }

}
//@}
