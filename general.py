import json
from loguru import logger
from spade.behaviour import OneShotBehaviour
from spade.template import Template
from spade.message import Message
from pygomas.bditroop import BDITroop
from pygomas.bdifieldop import BDIFieldOp
from agentspeak import Actions
from agentspeak import grounded
from agentspeak.stdlib import actions as asp_action
from pygomas.ontology import HEALTH

from pygomas.agent import LONG_RECEIVE_WAIT

class BDIGeneral(BDIFieldOp):

        def add_custom_actions(self, actions):
            super().add_custom_actions(actions)

        
        @actions.add_function(".distance", (tuple,tuple, ))
        def _distancia(p1, p2):
            return ((p1[0]-p2[0])**2+(p1[2]-p2[2])**2)**0.5
        
        '''
            Given Agent position and soldiers tuple, returns the best 
            attack pattern by the moment.
        '''
        @actions.add_function(".gpunto", (tuple,  ))
        def _gpunto(pos):     
            soldiers = self.soldiers_count
            target = []

            X,Z,Y = pos
            if Y - X > 0:
                X += 20
            else:
                X -= 20

            target = [X,Z,Y]
                
            # /** TODO **/
            return target
        
            

