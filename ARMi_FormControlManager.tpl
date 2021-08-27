#TEMPLATE(ARMi_Form_Control_Manager,'ARMi Form Control Manager Templates'),FAMILY('ABC')
#!---------------------------------------------------------------------------------------------------------------------------------------------------------
#EXTENSION(ARMi_FormControlManager,'ARMi Cambiar Propiedades de Controles en Form'),PROCEDURE
#!---------------------------------------------------------------------------------------------------------------------------------------------------------
#Boxed
    #Display('Form Control Manager')
    #Display('Version 2.3')
    #Display('Copyright © 2021 by ARMi software solutions')
    #Display('www.armisoftware.com')
#EndBoxed
#Boxed
    #DISPLAY ('Premite cambiar la propiedades de controles en tiempo real.')
    #DISPLAY ('ANTES QUE NADA, necesita la tabla PAR_CTRLS que debe importar al dicconario')
    #DISPLAY ('y los procedimientos ARMi_FieldProperties y ARMi_FieldPropertiesEdit,')
    #DISPLAY ('que pueden ser importardos con el botón mas abajo.')
    #DISPLAY ('')
    #PROMPT('Puede Editar si  :',@S200),%PuedeEditar,DEFAULT('choose(1=1,true,0)'),REQ
    #DISPLAY ('Expresión, si es true, el usuario puede editar.')
    #DISPLAY ('')
    #PROMPT('Tecla para Editar:',KEYCODE),%TeclaHist,DEFAULT('CtrlF5'),REQ
    #DISPLAY ('')
#EndBoxed
#Display()
#Prepare
    #Declare(%scExists)
    #SET(%scExists,CALL(%scExistsGroup))
#EndPrepare
#enable(%scExists=0)
    #Button('Importar Procedimientos Necesarios'),WhenAccepted(%ImportarProcedimientos()),at(,,180)
    #EndButton
#endEnable
#!------------------------------------------------------------------------------
#AT (%GlobalMap)
    MODULE('Undocumented_RTL_FEQ_ToString')
       FEQ_ToString(SIGNED FEQ),*CSTRING,RAW,NAME('Cla$FIELDNAME')
    END
#ENDAT
#!------------------------------------------------------------------------------
#AT( %WindowManagerMethodCodeSection, 'Init', '(),BYTE'),PRIORITY(8360),DESCRIPTION('Graba controles por defecto y lee valores actuales')
!GRABA PAR_CTRLS POR DEFECTO Y LEE EL QUE LE CORRESPONDE SI EXISTE
setcursor(cursor:wait)
Access:PAR_CTRLS.open()

!LEE CAMBIOS PARA TODOS, GRUPO Y USUARIO
LOOP FLD# = FIRSTFIELD() TO LASTFIELD()
  clear(pct:record)
  ID#=0
  PCT:USU_ID   = 0 !TODOS
  PCT:PROCEDIMIENTO = GlobalErrors.GetProcedureName()
  PCT:NOMBRE_FEQ   = FEQ_ToString(fld#)
  if NOT Access:par_ctrls.fetch(PCT:xUSU_PRO_PCT)
     ID#=PCT:ID
  END
  IF ID#>0 and FLD#{PROP:Type}<>create:sheet !sheet lo dejo solo para cuando tenga tamaño y posicion
     FLD#{PROP:TEXT} =PCT:TEXT
     fld#{prop:Disable}=PCT:DISABLE
     fld#{prop:Hide}=PCT:HIDE
     IF PCT:COLUMNA  = 0
        fld#{prop:Req}=PCT:REQUIRED
        fld#{prop:READONLY}=PCT:READONLY
        if self.Request=InsertRecord 
            change(fld#,PCT:PRIME)
            fld#{PROP:Touched} = TRUE 
        END
     END
  END   
END
Access:PAR_CTRLS.close()
setcursor()
#ENDAT

#AT( %WindowManagerMethodCodeSection, 'SetAlerts', '()'),PRIORITY(2500),DESCRIPTION('Alerta Tecla de Control props')
ALERT(%TeclaHist)
#ENDAT

#AT(%WindowManagerMethodCodeSection,'TakeEvent','(),BYTE'),PRIORITY(2500),DESCRIPTION('Detecta click en Regiones de F5')
  !detecto Regiones para edicion de controles
  ctl#=accepted()
  IF ctl# and ctl#>1000 and ctl#{PROP:TYPE}=CREATE:region
      fld#=ctl#-1000
      ARMi_FieldPropertiesEdit( |
            GlobalErrors.GetProcedureName(),|
            FEQ_ToString(fld#),|
            fld#{PROP:type},|
            fld#{prop:feq},|
            FLD#{PROP:TEXT},|
            fld#{prop:Disable},|
            fld#{prop:Hide},|
            FLD#{PROP:USE},|
            fld#{prop:Req},|
            fld#{PROP:READONLY},|
          )
     !string pProcedure,string pNombreFeq,long pType,long pFeq,string pText,long pDisable,long pHide,string pUse,long pReq,long pReadOnly
          
     !message(fld#{prop:text})
     FLD#{PROP:TEXT} =PCT:TEXT
     fld#{prop:Disable}=PCT:DISABLE
     fld#{prop:Hide}=PCT:HIDE
     IF PCT:COLUMNA  = 0
        fld#{prop:Req}=PCT:REQUIRED
        fld#{prop:READONLY}=PCT:READONLY
        if self.Request=InsertRecord 
            change(fld#,PCT:PRIME)
            fld#{PROP:Touched} = TRUE 
        END
     END
  END
#ENDAT


#AT( %WindowEventHandling, 'AlertKey'),PRIORITY(5000),DESCRIPTION('Detecta Tecla de Control Props y Edita')
IF KEYCODE()=%TeclaHist and %PuedeEditar=true
  if self.request=InsertRecord
    cho# = POPUP('{{' & |
                     '['&PROP:Icon&'(~prnfile.ico)]Modificar Controles en Ventana<9>|' & |
                     '['&PROP:Icon&'(~prnfile.ico)]Editar Todos los Controles<9>|' & |
                     '['&PROP:Icon&'(~prnfile.ico)]Regenerar Controles por Defecto<9>|' & |
                 '}',10,10,1 )
    CASE cho#
    OF 1
        setcursor(cursor:wait)
        fld#=0
        LOOP FLD# = FIRSTFIELD() TO LASTFIELD()
            if fld#>1000 then break end
            IF fld#{PROP:type}=create:sheet THEN SHEET#=FLD# END
            IF fld#{PROP:type}=create:TAB THEN TAB#=FLD# END
            if inlist(fld#{PROP:type},create:panel,create:line,create:box,create:sstring,create:string)
                cycle
            end  
            !if fld#{PROP:hide}=true then cycle end !no es mala idea pero si no lo agrego no lo puedo editar
            PAR# = fld#{PROP:Parent}
            IF PAR#{PROP:TYPE}<>CREATE:SHEET AND PAR#{PROP:TYPE}<>CREATE:TAB  AND PAR#{PROP:TYPE}<>CREATE:window
                IF TAB#>0 THEN PAR#=TAB# ELSE PAR#=SHEET# END 
            END
            NewBox#=1000+fld#                
            if fld#{PROP:type}=create:tab
                CREATE(NewBox#,CREATE:region,FLD#)
                NewBox#{PROP:Xpos}  = SHEET#{PROP:Xpos}!+SHEET#{PROP:Width}-6
                NewBox#{PROP:Ypos}  = SHEET#{PROP:Ypos}+10!SHEET#{PROP:Height}-6
            ELSE
                CREATE(NewBox#,CREATE:region,PAR#)
                NewBox#{PROP:Xpos}  = fld#{PROP:Xpos}-3
                NewBox#{PROP:Ypos}  = fld#{PROP:Ypos}-3
            END
            NewBox#{prop:color} = color:blue
            NewBox#{PROP:Width} = 8!fld#{PROP:Width}+4
            NewBox#{PROP:Height}= 8!fld#{PROP:Height}
            NewBox#{prop:linewidth} = 2
            UNHIDE(NewBox#)  
        END
        setcursor()
    of 2
       Access:PAR_CTRLS.open()
       PCT:PROCEDIMIENTO = GlobalErrors.GetProcedureName()
       ARMi_FieldProperties(PCT:PROCEDIMIENTO)
       Access:PAR_CTRLS.close()
    of 3
        Access:PAR_CTRLS.open()
        setcursor(cursor:wait)
        LOOP FLD# = FIRSTFIELD() TO LASTFIELD()
          PCT:USU_ID   = -1 !POR DEFECTO
          PCT:PROCEDIMIENTO = GlobalErrors.GetProcedureName()
          PCT:NOMBRE_FEQ   = FEQ_ToString(fld#)
          if inlist(fld#{PROP:type},create:sheet,create:list,create:panel,create:line,create:box,create:string)
            cycle
          end  
          if Access:par_ctrls.fetch(PCT:xUSU_PRO_PCT)
              PCT:USU_ID   = -1 !POR DEFECTO
              PCT:PROCEDIMIENTO = GlobalErrors.GetProcedureName()
              PCT:FEQ      = fld#{prop:feq}
              PCT:NOMBRE_FEQ   = FEQ_ToString(fld#) 
              PCT:COLUMNA  = 0
              PCT:TEXT     = FLD#{PROP:TEXT}
              PCT:DISABLE  = fld#{prop:Disable}
              PCT:HIDE     = fld#{prop:Hide}
              if inlist(fld#{PROP:type},create:entry,create:text)
                PCT:PRIME    = FLD#{PROP:USE}
                PCT:REQUIRED = fld#{prop:Req}
                PCT:READONLY = fld#{PROP:READONLY}
                PCT:COLUMNA  = 0  !SON EDITABLES
              else
                PCT:REQUIRED = 0
                PCT:READONLY = 0
                PCT:PRIME    = '' 
                PCT:COLUMNA  = 1  !NO SON EDITABLES
              end              
              Access:par_ctrls.Insert()
          end
        END
        setcursor()
        Access:PAR_CTRLS.close()
    end    
  ELSE
    message('Debe estar Agregando un registro para poder modificar controles.','Atención!',ICON:Asterisk)
  end
END
#ENDAT
#!------------------------------------------------------------------------------
#GROUP(%ImportarProcedimientos)
    #IMPORT('ARMi_FormControlManager.Txa')
#!------------------------------------------------------------------------------
#GROUP(%scExistsGroup),Preserve
  #FOR(%Procedure),Where(lower(%Procedure)=lower('ARMi_FieldProperties') or lower(%Procedure) = lower('ARMi_FieldPropertiesEdit'))
    #RETURN(1)
  #ENDFOR
  #RETURN(0)
#!------------------------------------------------------------------------------
