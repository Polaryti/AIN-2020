//TEAM_AXIS (defensa)

+flag (F): team(200)
  <-
  .create_control_points(F,25,3,C);
  +control_points(C);
  .length(C,L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0);
  .print("Got control points").


+target_reached(T): patrolling & team(200)
  <-
  ?patroll_point(P);
  -+patroll_point(P+1);
  -target_reached(T).

+patroll_point(P): total_control_points(T) & P<T
  <-
  ?control_points(C);
  .nth(P,C,A);
  .goto(A).

+patroll_point(P): total_control_points(T) & P==T
  <-
  -patroll_point(P);
  +patroll_point(0).
  

/* ESTRATEGIA DE PAQUETES DE SALUD */
/* Creencia que anula la estrategia */
+health(H): H >= 20 & solicitandoSalud
	<-
	-solicitandoSalud.

/* Creencia que dispara la estrategia */
+health(H): H < 20 & not solicitandoSalud
	<-
	+solicitandoSalud.

/* Solicitud al general */
+solicitandoSalud
	<-
	.print("Agente solicitando un paquete de vida.");
	-+medicoPOS([]);
	-+medicoID([]);
	.get_service("general");
	?general(General);
	?position(Pos);
	.send(General, tell, solicitudDeSalud(Pos));
	.wait(1500).



/* ESTRATEGIA DE PAQUETES DE MUNICIÓN */
/* Creencia que anula la estrategia */
+ammo(A): A >= 20 & solicitandoMunicion
	<-
	-solicitandoMunicion.

/* Creencia que dispara la estrategia */
+ammo(A): A < 20 & not solicitandoMunicion
	<-
	+solicitandoMunicion.

/* Solicitud al general */
+solicitandoMunicion
	<-
	.print("Agente solicitando un paquete de munición.");
	-+operativoPOS([]);
	-+operativoID([]);
	.get_service("general");
	?general(General);
	?position(Pos);
	.send(General, tell, solicitudDeMunicion(Pos));
	.wait(1500).


/*VISUALIZA UN ENEMIGO*/	
+enemies_in_fov(ID, Type, Angle, Distance, Health, Position)
	<-
	+objetivoLocalizado.
	
+objetivoLocalizado
	<-	
	.print("He visualizado al enemigo.");
	.get_service("general");
	?general(General);
	.send(General, tell, solicitudDeInstrucciones(Position));
	.look_at(Position);
    .shoot(10, Position);
	.wait(1000).