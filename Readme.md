<center> <h1>A la découverte de SDN</h1> </center>

Ce TP doit vous permettre de comprendre un peu mieux le fonctionnement de SDN, ainsi que son intérêt et ses possibles applicationx au travers :
* la prise en main d'un émulateur de réseaux virtuels (Mininet);
* l'analyse du fonctionnement du protocole Openflow;
* la prise en main d'un contrôleur SDN : Ryu (il ne s'agit bien sûr que d'un seul contrôleur et bien d'autres sont présents sur le marché : ONOS, OpenDayLight, etc.);
* du développement d'applications SDN basiques.

## 1. Mininet ##

Mininet, basé sur de la virtualisation d'OS, est un émulateur permettant de créer et d'interagir en local un réseau virtuel.

### 1.1 Prise en main ###

Pour commencer, lancez mininet avec la topologie par défaut, pour ceci, utilisez la commande suivante en mode root :

`sudo mn --switch=ovsk,protocols=OpenFlow13`

Nous verrons dans les parties suivantes à quoi servent les indications correspond au type de switch et au type de protocole.

Une fois que vous avec tapé cette commande, vous vous retrouvez à l'intérieur du shell mininet. Différentes commandes peuvent y être utiles :

```console
mininet> exit   #permet de quitter mininet

mininet> help   # permet d'afficher les commandes qui peuvent être utilisées avec cet émulateur

mininet> h1 ping h2 # montre comment faire un ping depuis h1 vers h2
```

**1.1.1.** De quoi est composée la topologie par défaut de mininet (combien de switch openflow et combien d'hôtes) ?

**1.1.2.** À quoi servent les commandes pingall, iperf, xterm, ifconfig, dump, links et net de mininet ?

**1.1.3.** Les switchs de votre instance mininet son configurés en "learning switch" par défaut.
  * Qu'est de qu'un "learning switch" ? Quel est le résultat de pingall lorsque le learning switch est utilisé ?
  * Quittez mininet et rédémarrer en désactivant le contrôleur (`--controller none`). Quel est le résultat du pingall ? Quel semble donc être le rôle du contrôleur dans une architecture SDN ?

*Note :* Dans cette partie comme dans la suite de ce TP certaines commandes pourront s'avérer utilises, notamment `mn -c` qui pourra vous permettre en cas de problèmes de faire un clean un de mininet.

### 1.2 Définition de topologies customisées ###

Mininet permet nativement de définir de façon simple un grand nombre de topologies au travers de l'utilisation de différentes arguments.
Jusqu'à présent la topologie que nous avons utilisée est composée de deux hôtes (h1,h2) et d'un switch (s1).

La commande que nous avons utilisée jusqu'ici correspond donc à une topologie d'arbre avec une profondeur de 1 et un fanout de 2 et aurait donc pu être écrite comme suit :
`sudo mn --topo=tree,depth=1,fanout=2`

**1.2.1.** Si l'on modifie maintenant cette topologie et que l'on crée une topologie d'une profondeur de 3 et d'un fanout de 4, combien y-a-t-il de switches ? Combien d'hôtes ? Combien de liens et enfin combien de contrôleurs ? A quel switch est relié l'hôte 25 ? (Pour répondre à cette question, vous devrez vous servir des différentes commandes associées à Mininet découvertes dans la partie 1.1)

Mininet dispose d'une API python. Grâce à cela, en utilisant cette API python, il est possible en quelques lignes de créer ses propres topologies customisées.

IMAGE

Nous allons donc maintenant essayer de créer notre propre topologie correspondant à l'image ci-dessus. Cette topologie est donc composée de deux "core switches" (s104) et (s105), de 3 "aggregation switches" ainsi que de 8 autres.

Pour parvenir à recréer cette architecture, vous allez pouvoir vous inspirer du code ci dessous.

```ruby
from mininet.topo import Topo

class CustomTopo(Topo):
    "Simple topology example."

    def __init__(self):
        "Create custom topo."

        # Initialize topology
        Topo.__init__(self)

        # Add hosts and switch
        s1 = self.addSwitch('s1')
        h1 = self.addHost('h1')
        h2 = self.addHost('h2')

        # Add links
        self.addLink(h1,s1)
        self.addLink(h2,s1)

topos = {'customtopo': (lambda: CustomTopo())}

```

On peut noter que 3 APIs sont essentielles à la définition d'une topologie : `addSwitch`, `addHost` et `addLink`.

**1.2.2.** Créer un fichier python dans lequel vous allez grâce à ces différentes fonctions créer une topologie qui correspondra à la topologie décrite dans la figure ci-dessus. Pensez dans le rapport à fournir le code permettant de gérer cette topologie.

Une fois ce code écrit vous allez pouvoir le lancer avec mininet pour en comprendre le bon fonctionnement.

Pour ce faire, vous allez pour la première fois pouvoir utiliser le contrôleur qui sera présenté et utilisé dans la suite de ce TP: RYU. Il existe de nombreux contrôleurs SDN, parmi lesquels ONOS et OpenDAyLight sont les plus connus. Toutefois Ryu est également un contrôleur utilisé, facile à prendre en main et à installer. Pour cette raison, il a été choisi dans le cadre de ce TP.

Ce que nous allons faire ici est simplement :
  * Utiliser le contrôleur Ryu ainsi que son interface graphique pour pouvoir observer la topologie que vous venez de définir et vérifier que cela a bien fonctionner

  * Indiquer à mininet que le contrôleur à utiliser n'est plus le contrôleur par défaut mais le contrôleur Ryu (on va tout simplement "brancher" le contrôleur Ryu sur la topologie que l'on vient de définir).

Pour de faire vous allez devoir entrer deux lignes de commande (dans deux terminaux différents) :

```console
ryu run --observe-links ryu/ryu/app/gui_topology/gui_topology.py # dans le terminal 1

sudo mn --custom <lien vers fichier custom>.py --topo mytopo --controller remote --link tc --switch=ovsk,protocols=OpenFlow13

```

Ici la première ligne va permettre de lancer le contrôleur ce qui va nous donner accès à l'interface graphine.
La seconde ligne de commande va permettre d'indiquer quel est le fichier contenant des topologies doit être utilisé, et à l'intérieur de ce fichier quelle topologie est visée ainsi que le choix du contrôleur : un contrôleur externe, Ryu.

**1.2.3.** Affichez votre topologie à l'aide de Ryu, pour ce faire connectez vous à l'adresse `http://localhost:8080` dans un navigateur. Pensez à joindre au rapport une capture d'écran témoignant du fait que votre topologie est bien en place.

*Note :* L'option `--link tc` doit permettre de spécifier différents types d'option concernant les links (bandwidth, delay, loss) et est nécessaire.

**1.2.4.** Maintenant que cette topologie est définie nous allons effectuer quelques tests :
  * Quel est le résultat du `pingall` ?
  * Que ce passe-t-il maintenant si l'on supprime le switch s105 et tous les liens qui s'y rattachent ?

Comme vous pouvez le voir dans le dossier `ryu/ryu/app/`, et comme nous le verrons dans la suite de ce TP, il existe de nombreux exemples différents d'utilisation de Ryu et des contrôleurs et switches. On peut notamment observer que certaines (simple_switch_stp.py) proposent une utilisation de STP.

**1.2.5** Qu'est ce que le Spanning Tree Protocol (STP) ? Quel pourrait bien être son intérêt ici ? Pourrait il nous aider à corriger le problème découvert ? Développez un peu.

  ## 2. Openflow ##

Comme vous le savez, une architecture SDN est composée de trois couches principales : Application - Contrôle - Infrastructure. Le protocole le plus répandu pour la communication entre la couche de contrôleurs (contrôleurs SDN) et la couche infrastructure (switches) est Openflow. Il s'agit donc d'un protocole de communication permettant au contrôleur d'avoir accès au "Forwarding plane" des switches et routeurs. Différentes version de ce protocole existent et dans le cadre de ce TP, comme vous avez déjà pu le comprendre, nous allons nous intéresser à la version 1.3.

### 2.1 Retour sur le fonctionnement de switches traditionnels ###


**2.1.1.** Rappelez le fonctionnement des switches L2  traditionnels (ie switch de niveau 2 du modèle OSI) :
  * Existe-t-il une séparation entre le plan de contrôle t le plan des données ?
  * Quel type de données contient la "Forwarding Table" ? Quel type de données sont traitées au niveau 2 ?
  * Comment cette table est elle mise à jour ?

### 2.2 Switch SDN basés sur Openflow ###

Nous allons maintenant essayer de comprendre quelle est la principale différence entre ces switches traditionnels et les switches openflow.

Pour cela nous allons agir en deux étapes, tout d'abord théorique, puis pratiques.

**2.2.1.** Pour commencer, lister les principaux messages qu'OpenFlow doit permettre d'échanger (Hello, PacketIn, PacketOut, FlowRemoved, Echo, etc.) ainsi que leur objectif. Pour cela vous pourrez vous servir de la documentation présente ici : https://ryu.readthedocs.io/en/latest/ofproto_ref.html. N'oubliez pas que l'on travaille actuellement avec la version 1.3.

Nous allons maintenant essayer de voir ce que cela peut donner en pratique. Pour cela nous allons avoir besoin dans un premier temps de relancer un contrôleur Ryu avec un switch de niveau 2 :

`ryu-manager ryu/ryu/app/simple_switch_13`

Dans un second terminal nous allons lancer l'émulateur Mininet avec une topologie linéaire composée de 6 switches :

`sudo mn --controller=remote --switch=ovsk,protocols=OpenFlow13 --topo=linear,6`

Ce que nous allons maintenant vouloir faire est observer les échanges se produisant entre les différents switches, ainsi qu'entre les switches et le contrôleur.

Pour ce faire nous allons lancer Wireshark et observer les échanges qui se produisent en local.

Lancez maintenant la commande pingall.

**2.2.2.** Quel type de commandes OpenFlow sont capturées par wireshark, d'après la partie théorique quelle est leur rôle ?

**2.2.3.** Si vous relancez à nouveau la commande pingall, quelle différence observez vous avec la question précédente ? Pourquoi ?

**2.2.4.** Comment fonctionne donc ces switches SDN ? Quelle est la principale différence avec les switches traditionnels ?

**2.2.5.** Quel type de données sont traitées ici par le "forwarding plane" (voir contenu packetIn et packetOut)? Qel est le rôle du contrôleur ici ?


*Note :* En utilisant en ligne de commande l'outil `ovs-ofctl` il vous est également possible de superviser et de gérer les switches OpenFlow du réseau que vous venons de créer. Ainsi il est possible de récupérer des informations concernant par exemple l'état actuel d'un switch OpenFlow, incluant ses caractéristiques, sa configuration et ses tables d'entrées.

**2.2.6** Quelles informations permettent par exemple de récupérer les commandes suivantes ?

```console
> sudo ovs-vsctl show
> sudo ovs-ofctl -O OpenFlow13 show s1
> sudo ovs-ofctl -O Openflow13 dump-flows s1
```

  ## 3. Ryu ##
  
Maintenant que nous avons compris comment utiliser l'émulateur Mininet (création de réseau virtuel) ainsi que la base du fonctionnement d'OpenFlow (type de messages échangés, rôle du contrôleur) nous allons essayer de développer des applications au sein du contrôleur Ryu en nous concertrant sur l'interface Sud et les échanges entre contrôleur et infrastructure et de découvrir quelles sont les possibilités offertes par Ryu : 
  * Gestion de switches de niveau 3
  * Gestion de switches de niveau 4
  * Définition de timeouts pour des entrées dans la table des flux (flow entries)
  * Définition de priorités pour les flux (flow priority)
  * Ryu et API REST
    - Firewall
    - QoS
  
### 3.1 Gestion de switches de niveau 3 ###

Dans la partie 2 nous nous sommes concentrés sur des switch de niveau 2 (OSI) en utilisant un exemple d'application proposé par Ryu permettant de mettre en place un contrôleur gérant ce type d'équipements. Ce que nous allons faire maintenant est d'essayer de comprendre le code existant et de le modifier pour transformer l'application en une application oeuvrant au niveau 3 (OSI).

**3.1.1** Pour commencer, rappelez quelle est la différence entre un switch de niveau 2 et un switch de niveau 3. Quel pourrait être l'intérêt de faire fonctionner le contrôleur à ce niveau ?

Maintenant nous allons essayer de comprendre le code à notre disposition : `ryu/ryu/app/simple_switch_13`.

Pour ce faire ouvrez ce fichier.

Il contient bien entendu les différentes libraries necessaires au fonctionnement de l'application

```ruby
from ryu.base import app_manager    # permet d'accéder à l'application

# différents éléments permettant de capturer des évènements correspondant à la réception d'un packet OpenFlow
from ryu.controller import ofp_event    
from ryu.controller.handler import CONFIG_DISPATCHER, MAIN_DISPATCHER
from ryu.controller.handler import set_ev_cls

from ryu.ofproto import ofproto_v1_3    # spécification de la version d'OpenFlow à utiliser
from ryu.lib.packet import packet
from ryu.lib.packet import ethernet
from ryu.lib.packet import ether_types
```

  
