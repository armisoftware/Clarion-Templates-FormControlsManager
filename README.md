# Clarion-Templates-FormControlsManager
Template para poder programar las porpiedades de los controles de un Form en tiempo real.

El objetivo de este template es poder cumplir con los pedidos de los clientes respecto de que ver y como
en cada form del sistema.
Permite entonces sin tener que modificar la ventana, recompilar, instalar, etc modifcar los controles a gusto.
Como ejmplo puede ser ocultar controles que el cliente no usa, deshabilitar controles, 
modificar "pictures" en entries, cambiar prompts, etc
Todo sin tocar una linea de código.

Esto no pasa en todos los forms, por eso el template es solo para importar en Forms.

Este template es por ahora solo para cadena ABC.

Pasos para implementar:
- Copiar los 3 archivos en la carpeta Clarioxx\accesories\templates\win
- Registrar en el Registry el template con el archivo: ARMi_FormControlManager.tpl
- Importar al diccionario de la solucion que se trate el ARMi_FormControlManager.dctx
  Esto creará la tabla PAR_CTRLS en su diccionario.
  Esta tabla esta por defecto seteada como MSSQL y con variables en el Owner para una conexion SQL.
  Si trabaja con TPS simplemente borre las variables en Owner y cambie el Driver a TOPSPEED.
- Abra su aplicación
- Elija el form al cual agrgarle el template, Insert, tipee armi para acercarse al mismo, elija y listo.
- El template le pedirá dos datos:
  1- Una expresion para evaluar y si cuyo resultado es true, entonces el usuario actual puede usarlo.
     Como ejemplo si queremos usarlo solo para supervisores, agaregar algo como:
     CHOOSE(Glo:EsSupervisor,true,false)
  2- La tecla para utilizar el Form Controls Manager   
- En la misma ventana, pulse el botón "Importar Procedimientos Necesarios", 
  esto hara que se importen dos procediemientos llamados "ARMi_FieldProperties" y "ARMi_FieldPropertiesEdit"
  que son los que se utilizarán para las ediciones.
- Compile normalmente.

El código se activa solo si el form esta en Insert.
Al pulsar la tecla elegida, CTRLF5 por defecto aparecerá un menu popup para elegir que acción realizar.
- Modificar controles en ventana
  Esta opción dibuja un box azul en la esquina superior izquierda de cada control.
  Haciendo click en el box se abre la ventana de edición de las propiedades de ese control.
  Se pueden ver los valores por defecto, o sea los programados en la ventana original y modificarlos.
- Editar Todos los Controles
  Esta opción es similar solo que se abre un Browse para modificar cualquier control con edit in place.
- Regenerar controles por defecto
  Esta opción es para cuando se hace alguna modificación de la ventana original y el control nuevo no aparece en la lista.
  
Es todo, espero les sirva.  


