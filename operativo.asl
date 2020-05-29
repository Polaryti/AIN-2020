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
	


/* ESTRATEGIA PARA IR EN COLMENA A POR UN ENEMIGO */
/* Visualizo un enemigo y no he avisado al General */	
+enemies_in_fov(_, _, _, _, _, Position): not colmena(_) & not atacando
	<-
	?general(General);
	.send(General, tell, solicitudDeInstrucciones(Position));
	// Mientras espera ordenes, ataca
	.look_at(Position);
    .shoot(3, Position);
	.abolish(enemies_in_fov(_,_,_,_,_,_));
	// Para no sobrecargar al General
	.wait(1000).

/* Visualizo un enemigo */
+enemies_in_fov(_, _, _, _, _, Position)
	<-
	.look_at(Position);
    .shoot(3, Position);
	.abolish(enemies_in_fov(_,_,_,_,_,_)).
	
+objetivoLocalizado
	<-	
	.print("He visualizado al enemigo.");
	.get_service("general");
	?general(General);
	.send(General, tell, solicitudDeInstrucciones(Position));
	.look_at(Position);
    .shoot(10, Position);
	.wait(1000).
	
+solicitudDeColmena(Pos)[source(A)]: not (ayudandoc(_))
	<-
	?position(MiPos);
	.send(A, tell, respuestaColmenaF(MiPos));
	+ayudandoc(Pos);
	-solicitudDeColmena(_);
	.print("enviada propuesta de apoyo").
	
/* Me aceptan la respuesta de solicitud de apoyo */
+solicitudAceptadaC[source(A)]: not solicitudAceptadaC(_) & not atacando
	<-
	// Eliminamos las creencias de patrulla
	-control_points(_);
	-total_control_points(_);
	-patrolling;
	-patroll_point(_);

	+atacando;
	.goto(Pos);
	-solicitudAceptadaC(_).
	
/* Me rechazan la respuesta de solicitud de ayuda */
+solicitudDenegadaC[source(A)]: ayudandoc(Pos)
	<-
	.print("Nada, a seguir dándo vueltas");
	-ayudandoc(Pos).
	
/* Llego al objetivo del ataque en colmena */
+target_reached(Pos): atacando
	<-
	-atacando;
	// Volvemos a generar las coordenadas de la patrulla en rombo (por si se ha movido la bandera)
	.generarPatrulla.