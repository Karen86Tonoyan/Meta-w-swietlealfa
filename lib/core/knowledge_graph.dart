/// Graf wiedzy ALFA — loader i zapytania.
/// Dane: docs/knowledge/graph.json (węzły + krawędzie relacyjne).
/// CERBER używa grafu, by wiedzieć CO pilnuje i gdzie eskalować anomalie.
library;

import 'dart:convert';

class KgNode {
  final String id, type, label;
  final Map<String, dynamic> extra;
  const KgNode(this.id, this.type, this.label, this.extra);
}

class KgEdge {
  final String from, to, rel;
  const KgEdge(this.from, this.to, this.rel);
}

class KnowledgeGraph {
  final Map<String, KgNode> nodes;
  final List<KgEdge> edges;
  const KnowledgeGraph(this.nodes, this.edges);

  factory KnowledgeGraph.fromJson(String jsonStr) {
    final j = jsonDecode(jsonStr) as Map<String, dynamic>;
    final nodes = <String, KgNode>{
      for (final n in j['nodes'] as List)
        (n['id'] as String): KgNode(
          n['id'], n['type'], n['label'],
          Map<String, dynamic>.from(n)..removeWhere((k, _) => k == 'id' || k == 'type' || k == 'label'),
        ),
    };
    final edges = [
      for (final e in j['edges'] as List)
        KgEdge(e['from'] as String, e['to'] as String, e['rel'] as String),
    ];
    return KnowledgeGraph(nodes, edges);
  }

  /// Co sprawdza dany agent (np. cerber_bot → ip, device_fp, token).
  List<KgNode> checkedBy(String agentId) => [
        for (final e in edges.where((e) => e.from == agentId && e.rel == 'sprawdza'))
          if (nodes[e.to] != null) nodes[e.to]!,
      ];

  /// Gdzie eskalować anomalię z danego węzła (relacja raportuje_do / filtruje_przez).
  List<KgNode> escalationPath(String nodeId) => [
        for (final e in edges.where(
            (e) => e.from == nodeId && (e.rel == 'raportuje_do' || e.rel == 'filtruje_przez')))
          if (nodes[e.to] != null) nodes[e.to]!,
      ];

  /// Sąsiedzi węzła (obie strony krawędzi).
  List<({KgNode node, String rel, bool outgoing})> neighbors(String id) => [
        for (final e in edges.where((e) => e.from == id))
          if (nodes[e.to] != null) (node: nodes[e.to]!, rel: e.rel, outgoing: true),
        for (final e in edges.where((e) => e.to == id))
          if (nodes[e.from] != null) (node: nodes[e.from]!, rel: e.rel, outgoing: false),
      ];
}
