/*
	Autores: Antoni Mestre Gascón & Mario Campos Mocholí
	Clase: Medico
	Estrategia: Defensa (AXIS)
		Este tipo de médico siempre se quedara cerca de la bandera generando
		paquetes y cuando un soldado solicite ayude, se la dara.
*/

+flag (F): team(200) 
  <-
  .print(Grito);
  .create_control_points(F, 20, 5, C);
  +control_points(C);
  .length(C, L);
  +total_control_points(L);
  +creando_reservas; // Creencia que indica que el agente está en ESTADO = Patrullando y creando paquetes
  +patroll_point(0).


+target_reached(T): creando_reservas & team(200) 
  <-
  .print("Creado un paquete de salud.");
  .cure;
  ?patroll_point(P);
  -+patroll_point(P + 1);
  -target_reached(T).

+patroll_point(P): total_control_points(T) & P < T 
  <-
  ?control_points(C);
  .nth(P, C, A);
  .goto(A).

+patroll_point(P): total_control_points(T) & P == T
  <-
  -patroll_point(P);
  +patroll_point(0).
  
  
// ESTRATEGIA DE RECEPCIÓN Y ENVIAMIENTO DE SOLICITUDES DE AYUDA DE SALUD
/* Recibo solictud de ayuda */
+solicitudDeSalud(Pos)[source(A)]: not (ayudando(_,_))
	<-
	?position(MiPos);
	.send(A, tell, respuestaVida(MiPos));
	+ayudando(A, Pos);
	-solicitudDeSalud(_);
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
	.print("Paquete de salud para: ", A);
	.cure;
	?miPosition(P); // Esto no lo veo, falta algo
	.goto(P);
	-ayudando(A, Pos).
	
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
	
+solicitudDeColmena(Pos)[source(A)]: not (ayudandoc(_))
	<-
	?position(MiPos);
	.send(A, tell, respuestaColmenaM(MiPos));
	+ayudandoc(Pos);
	-solicitudDeColmena(_);
	.print("enviada propuesta de apoyo").
	
/* Me aceptan la respuesta de solicitud de apoyo */
+solicitudAceptadaC[source(A)]: ayudandoc(Pos)
	<-
	.print("Yendo a ", Pos," a matar");
	.goto(Pos).
	
/* Me rechazan la respuesta de solicitud de ayuda */
+solicitudDenegadaC[source(A)]: ayudandoc(Pos)
	<-
	.print("Nada, a seguir dándo vueltas");
	-ayudandoc(Pos).