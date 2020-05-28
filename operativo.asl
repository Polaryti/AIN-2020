//TEAM_AXIS

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
  .print("AMMOPACK!");
  .reload;
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


// ESTRATEGIA DE RECEPCIÓN Y ENVIAMIENTO DE SOLICITUDES DE AYUDA DE MUNICIÓN
/* Recibo solictud de ayuda */
+solicitudDeMunicion(Pos)[source(A)]: not (ayudando(_,_))
	<-
	?position(MiPos);
	.send(A, tell, respuestaMunicion(MiPos));
	+ayudando(A, Pos);
	-solicitudDeMunicion(_);
	.print("enviada propuesta de ayuda").
	
/* Me aceptan la respuesta de solicitud de ayuda */
+solicitudAceptad[source(A)]: ayudando(A, Pos)
	<-
	.print("Ayudo al egente: ", A, "en la posicion: ", Pos);
	.goto(Pos).
	
/* Me rechazan la respuesta de solicitud de ayuda */
+solicitudDenegada[source(A)]: ayudando(A, Pos)
	<-
	.print("El agente ya no necesita de mi ayuda.");
	-ayudando(A, Pos).

/* Voy a la posición del agente que me ha aceptado */
+target_reached(T): ayudando(A, T)
	<-
	.print("Paquete de munición para: ", A);
	.reload;
	?miPosition(P); // Esto no lo veo, falta algo
	.goto(P);
	-ayudando(A, Pos).