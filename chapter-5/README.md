# Conhecendo o OCI (Oracle Cloud Infraestructure)

## Capítulo 5: Mais sobre Redes no OCI

Já estudamos o básico sobre redes no capítulo _[3.1 - Fundamentos do Serviço de Redes](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-3/3-1_fundamentos-redes.md)_ ao preparar e executar a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_ no _[OCI](https://www.oracle.com/cloud/)_. 

A ideia deste capítulo é dar continuidade em diversos outros cenários mais complexos, e que envolvem a conectividade do seu data center local (on-premises) ao _[OCI](https://www.oracle.com/cloud/)_. Começarei explicando como conectar várias _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ através de um recurso chamado _[DRG](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_. Em seguida criaremos uma _[VPN](https://pt.wikipedia.org/wiki/Rede_privada_virtual)_ e _[FastConnect](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/fastconnect.htm)_, que permitem um tipo de conexão permanente ao _[OCI](https://www.oracle.com/cloud/)_. Mostraremos suas diferenças e também a possibilidade de conexão com o _[Microsoft Azure](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/azure.htm)_, um serviço já disponível em algumas regiões.

Seguiremos para topologias mais sofisticadas que empregam o _"roteamento de trânsito"_. Interligaremos duas regiões diferentes para formar um _"Ambiente DR (Disaster Recovery)"_, e por fim utilizaremos múltiplos _[DRGs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_ para conectar múltiplas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ em diferentes _[tenants](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_.

Seguimos...

[5.1 - Conectando múltiplas VCNs através do DRG](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-1_mais-sobre-redes-multiplas-vcn-drg.md) <br>
[5.2 - VPN](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-2_mais-sobre-redes-vpn.md) <br>
[5.3 - FastConnect](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-3_mais-sobre-redes-fastconnect.md) <br>
[5.4 - Acesso ao Microsoft Azure](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-4_mais-sobre-redes-msazure.md) <br>
[5.5 - Roteamento de Trânsito](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-5_mais-sobre-redes-roteamento-transito.md) <br>
[5.6 - Ambiente DR (Disaster Recovery)](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-6_mais-sobre-redes-ambiente-dr.md) <br>
[5.7 - Múltiplos DRGs e múltiplas VCNs](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-7_mais-sobre-redes-multiplos-drgs-multiplos-vcns.md) <br>