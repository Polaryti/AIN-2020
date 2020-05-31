import json
import math
import random
import pygomas
from pygomas.map import TerrainMap
from loguru import logger
from spade.behaviour import OneShotBehaviour
from spade.template import Template
from spade.message import Message
from pygomas.bditroop import BDITroop
from pygomas.bdisoldier import BDISoldier
from pygomas.bdimedic import BDIMedic
from pygomas.bdifieldop import BDIFieldOp
from agentspeak import Actions
from agentspeak import grounded
from agentspeak.stdlib import actions 
from pygomas.ontology import HEALTH

from pygomas.agent import LONG_RECEIVE_WAIT

class BDIGeneral(BDITroop):
    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)
        
    @actions.add_function(".delete1", (int, tuple))
    def _delete(p, l):
        if p==0:
            return l[1:]
        elif p == len(l) -1:
            return l[:p]
        else:
            return tuple(l[0:p] + l[p+1:])

    @actions.add_function(".medicoMasCerca", (tuple, tuple))
    def _medico_mas_cercano(pos_sol, posiciones_agentes):
        '''
        Recibe dos parametros:
            pos_sol: Posicion de la unidad que solicita la ayuda.
            posicion_agentes: La lista de las posiciones de los agentes.
        
        return: La posición del agente más cercano.
        '''

        # Lista resultado de distancia a cada agente
        distancia_a_cada_agente = []
        
        # Recorremos la lista de agentes
        for posicion_agente in posiciones_agentes:
            # No tenemos en cuenta la componente Y
            distancia_a_cada_agente += [math.sqrt(math.pow(
                posicion_agente[0] - pos_sol[0], 2) + math.pow(posicion_agente[2] - pos_sol[2], 2))]

        # Ordenamos de menor a mayor distanca Euclidea
        distancia_aux = tuple(sorted(distancia_a_cada_agente))
        res = []
        if (len(distancia_aux) > 0):
            res += [distancia_a_cada_agente.index(distancia_aux[0])]
        # Si este método se activa siempre habrá, al menos, un operativo
        # Devolvemos la posicón del agente más cercano
        return tuple(res)


    @actions.add_function(".operativoMasCerca", (tuple, tuple))
    def _operativo_mas_cercano(pos_sol, posiciones_agentes):
        '''
        Recibe dos parametros:
            pos_sol: Posicion de la unidad que solicita la ayuda.
            posicion_agentes: La lista de las posiciones de los agentes.
        
        return: La posición del agente más cercano.
        '''
        
        # Lista resultado de distancia a cada agente
        distancia_a_cada_agente = []
        
        # Recorremos la lista de agentes
        for posicion_agente in posiciones_agentes:
            # No tenemos en cuenta la componente Y
            distancia_a_cada_agente += [math.sqrt(math.pow(
                posicion_agente[0] - pos_sol[0], 2) + math.pow(posicion_agente[2] - pos_sol[2], 2))]

        # Ordenamos de menor a mayor deistancia Euclidea
        distancia_aux = sorted(distancia_a_cada_agente)
        
        res = []
        if (len(distancia_aux) > 0):
            res += [distancia_a_cada_agente.index(distancia_aux[0])]
        # Si este método se activa siempre habrá, al menos, un operativo
        # Devolvemos la posicón del agente más cercano
        return tuple(res)


    @actions.add_function(".agentesMasCercanos1", (tuple, tuple))
    def _agentes_mas_cercanos1(pos_ene, posiciones_agentes):
        '''
        Recibe dos parametros:
            pos_ene: Posicion del agente enemigo detectado.
            posicion_agentes: La lista de las posiciones de los agentes.
        
        return: La posición del agente más cercano.
        '''
        # Lista resultado de distancia a cada agente
        distancia_a_cada_agente = []
        
        # Recorremos la lista de agentes
        for posicion_agente in posiciones_agentes:
            # No tenemos en cuenta la componente Y
            distancia_a_cada_agente += [math.sqrt(math.pow(
                posicion_agente[0] - pos_ene[0], 2) + math.pow(posicion_agente[2] - pos_ene[2], 2))]

        # Ordenamos de menor a mayor distancia Euclidea
        distancia_aux = sorted(distancia_a_cada_agente)
        # Si este método se activa siempre habrá, al menos, un operativo
        # Devolvemos la posicón del agente más cercano
        res = []
        if len(distancia_aux) > 0:
            res += [distancia_a_cada_agente.index(distancia_aux[0])  ]

        return tuple(res)

    @actions.add_function(".agentesMasCercanos2", (tuple, tuple))
    def _agentes_mas_cercanos2(pos_ene, posiciones_agentes):
        '''
        Recibe dos parametros:
            pos_ene: Posicion del agente enemigo detectado.
            posicion_agentes: La lista de las posiciones de los agentes.
        
        return: La posición del agente más cercano.
        '''
        # Lista resultado de distancia a cada agente
        distancia_a_cada_agente = []
        
        # Recorremos la lista de agentes
        for posicion_agente in posiciones_agentes:
            # No tenemos en cuenta la componente Y
            distancia_a_cada_agente += [math.sqrt(math.pow(
                posicion_agente[0] - pos_ene[0], 2) + math.pow(posicion_agente[2] - pos_ene[2], 2))]

        # Ordenamos de menor a mayor distancia Euclidea
        distancia_aux = sorted(distancia_a_cada_agente)
        # Si este método se activa siempre habrá, al menos, un operativo
        # Devolvemos la posicón del agente más cercano
        res = []
        if len(distancia_aux) > 1:
            res += [distancia_a_cada_agente.index(distancia_aux[0])]
            res += [distancia_a_cada_agente.index(distancia_aux[1])]

        return tuple(res)
        
    @actions.add_function(".distance", (tuple, tuple))
    def _distancia(p1, p2):
        return ((p1[0]-p2[0])**2+(p1[2]-p2[2])**2)**0.5
    
    @actions.add_function(".circuloInterior", (tuple))
    def _circuloInterior(posicion_bandera):
        '''
        Recibe un parametro: La posicición de la bandera.
        
        return: La lista de puntos de patrulla en circulo interior.
        '''
        # Distancia de creación del círculo
        distancia_de_circulo = 20

        punto_A = [posicion_bandera[0] - distancia_de_circulo, posicion_bandera[1], posicion_bandera[2]]
        punto_B = [posicion_bandera[0], posicion_bandera[1], posicion_bandera[2] - distancia_de_circulo]
        punto_C = [posicion_bandera[0] + distancia_de_circulo, posicion_bandera[1], posicion_bandera[2]]
        punto_D = [posicion_bandera[0], posicion_bandera[1], posicion_bandera[2] + distancia_de_circulo]
        positions = [tuple(punto_A), tuple(punto_B), tuple(punto_C), tuple(punto_D)]
        positions = random.sample(positions, len(positions))
        return tuple(positions)


    @actions.add_function(".circuloExterior", (tuple))
    def _circulo_exterior(posicion_bandera):
        '''
        Recibe un parametro: La posicición de la bandera.
        
        return: La lista de puntos de patrulla en circulo exterior.
        '''
        # Distancia de creación del círculo
        distancia_de_circulo = 50

        punto_A = [posicion_bandera[0] - distancia_de_circulo, posicion_bandera[1], posicion_bandera[2]]
        punto_B = [posicion_bandera[0], posicion_bandera[1], posicion_bandera[2] - distancia_de_circulo]
        punto_C = [posicion_bandera[0] + distancia_de_circulo, posicion_bandera[1], posicion_bandera[2]]
        punto_D = [posicion_bandera[0], posicion_bandera[1], posicion_bandera[2] + distancia_de_circulo]
        positions = [tuple(punto_A), tuple(punto_B), tuple(punto_C), tuple(punto_D)]
        positions = random.sample(positions, len(positions))
        return tuple(positions)

    @actions.add_function(".comprobarPuntos", (tuple))
    def _comprobarPuntos(puntos):
        ret = []
        for punto in puntos:
            sx=1
            sz=1
            cont = 2
            while (TerrainMap.can_walk(punto[0],punto[2]) == False):
                if cont % 2 == 1:
                    punto[0] = punto[0] + sx * int(cont / 2)
                    sx *= -1
                else:
                    punto[2] = punto[2] + sz * int(cont / 2)
                    sz *= -1
                cont +=1 
            ret += tuple(punto)
        return tuple(ret)

class SoldadoPropio(BDISoldier):
    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)