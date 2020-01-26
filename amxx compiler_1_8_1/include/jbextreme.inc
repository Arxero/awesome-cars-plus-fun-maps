/*
---------------------------------------------------------
   #  #  #    #===    ###    ##    #
  #    ##     #===   #      #  #    #
   #   #      #===    ###    ##    #
---------------------------------------------------------
jbextreme.inc
Library by <VeCo>

If you modify the code, please DO NOT change the author!
---------------------------------------------------------
Contacts:
e-mail: veco.kn@gmail.com
skype: veco_kn
---------------------------------------------------------
Changes log:
 -> v 1.0 = First release!
---------------------------------------------------------
Don't forget to visit http://www.amxmodxbg.org :)
---------------------------------------------------------
*/

#if defined _jbextreme_included
	#endinput
#endif

#define _jbextreme_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib jbextreme
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib jbextreme
	#endif
#else
	#pragma library jbextreme
#endif

/* is_user_simon
Този натив връща true ако играчът е Simon, и false - ако не е.

id - индекс на играча
*/
native is_user_simon(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
