# Conhecendo o OCI (Oracle Cloud Infraestructure)

## Capítulo 5: Mais sobre Redes no OCI

Já estudamos o básico sobre redes no capítulo _[3.1 - Fundamentos do Serviço de Redes](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-3/3-1_fundamentos-redes.md)_ ao preparar e executar a aplicação _[Wordpress](https://pt.wikipedia.org/wiki/WordPress)_ no _[OCI](https://www.oracle.com/cloud/)_. 

A ideia deste capítulo é dar continuidade em diversos outros cenários mais complexos, e que envolvem a conectividade do seu data center local (on-premises) ao _[OCI](https://www.oracle.com/cloud/)_. Começarei explicando como conectar duas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ diferentes através de um recurso chamado _[Local Peering Gateway (LGP)](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm#Local_VCN_Peering_Within_Region)_. Após isto, será apresentado o _[Dynamic Routing Gateway (DRG)](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_ que possibilita conectar múltiplas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ na mesma região, conexões mais persistentes através de _[VPN Site-to-Site](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ e _[FastConnect](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/fastconnect.htm)_. Mostraremos também a possibilidade de conexão direta com o _[Microsoft Azure](https://docs.oracle.com/pt-br/iaas/Content/Network/Concepts/azure.htm)_ por um serviço já disponível em algumas regiões.

Para concluír, criaremos topologias mais sofisticadas que empregam o chamado _"roteamento de trânsito"_. Interligaremos duas regiões diferentes para formar um _"Ambiente DR (Disaster Recovery)"_, e por fim, utilizaremos múltiplos _[DRGs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingDRGs.htm)_ para conectar múltiplas _[VCNs](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_ de diferentes _[tenants](https://docs.oracle.com/pt-br/iaas/Content/Identity/Tasks/managingtenancy.htm)_.

Seguimos...

[5.1 - Redes, redes e mais redes](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-1_mais-sobre-redes-redes-redes.md) <br>
[5.2 - Conectando múltiplas VCNs na mesma região](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-2_mais-sobre-redes-multiplas-vcn-lpg-drg.md) <br>
[5.3 - Conexão ao OCI através de VPN](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-3_mais-sobre-redes-vpn.md) <br>
[5.4 - Roteamento de Trânsito](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-4_mais-sobre-redes-roteamento-transito.md) <br>
[5.5 - Interligando diferentes Regiões](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-5_mais-sobre-redes-interligando-regioes.md)
[5.6 - FastConnect](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-6_mais-sobre-redes-fastconnect.md) <br>
[5.7 - OCI e Microsoft Azure](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-7_mais-sobre-redes-msazure.md) <br>
[5.8 - Múltiplos DRGs e múltiplas VCNs](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-8_mais-sobre-redes-multiplos-drgs-multiplos-vcns.md) <br>
[5.9 - Visualização através do Network Visualizer](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-9_mais-sobre-redes-net-visualizer.md) <br>
[5.10 - DNS Híbrido](https://github.com/daniel-armbrust/oci-book/blob/main/chapter-5/5-10_mais-sobre-redes-hybrid-dns.md) <br>
