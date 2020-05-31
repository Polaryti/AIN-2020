/* Creencia que se dispara cuando se inicia la partida */
+flag(F): team(200)
  <-
  !generarPatrulla.

/* El agente gira mientras patrulla */
+rolling
	<-
	.turn(1);
	.wait(100);
	-+rolling.


/* ESTRATEGIA DE PATRULLA EN ROMBO (EXTERIOR) */
/* Generamos unos puntos de control en rombo */
+!generarPatrulla
	<-
	.print("Operativo empezando a patrullar.");
	?flag(F);
	.circuloInterior(F, Pini);
	.comprobarPuntos(Pini,C);
	.length(C, L);
	+total_control_points(L);
	+patrolling;
	+rolling;
	+patroll_point(0).


+target_reached(T): patrolling & team(200) 
  <-
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


+ammo(A): A < 20
	<-
	.reload.
	

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
	.print("Ayudo al agente: ", A, " en la posicion: ", Pos);
	-rolling;
	-control_points(_);
	-total_control_points(_);
	-patrolling;
	-patroll_point(_);
	.goto(Pos).
	
/* Me rechazan la respuesta de solicitud de ayuda */
+solicitudDenegada[source(A)]: ayudando(A, Pos)
	<-
	.print("El agente ya no necesita de mi ayuda.");
	-ayudando(_, _).

/* Voy a la posición del agente que me ha aceptado */
+target_reached(T): ayudando(A, T)
	<-
	.print("Paquete de municion para: ", A);
	.reload;
	-ayudando(_, _);
	!generarPatrulla.
	


/* ESTRATEGIA PARA IR EN COLMENA A POR UN ENEMIGO */
/* Visualizo un enemigo y no he avisado al General */	
+enemies_in_fov(_, _, _, _, _, Position): not colmena(_) & not atacando
	<-
	.get_service("general");
	.wait(500);
	?general(General);
	.send(General, tell, solicitudDeInstrucciones(Position));
	.abolish(enemies_in_fov(_,_,_,_,_,_));
	// Para no sobrecargar al General
	.wait(1000).

/* Visualizo un enemigo */
+enemies_in_fov(_, _, _, _, _, Position)
	<-
	.look_at(Position);
    .shoot(5, Position);
	.abolish(enemies_in_fov(_,_,_,_,_,_)).
	
+objetivoLocalizado
	<-	
	.print("He visualizado al enemigo.");
	.get_service("general");
	.wait(500);
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
	.print("Soldado aceptando la solicitud de colmena.");
	-rolling;
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
	!generarPatrulla.