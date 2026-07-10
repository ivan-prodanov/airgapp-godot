class_name PoolManager
extends Node

onready var LOG: LOG = get_node("../Log")


var pool: Dictionary = {}


var in_use: Array = []

func add_node(node_path: NodePath):
	if node_path == null:
		LOG.err("[PoolManager] Cannot add null object to pool")
		return null
	var nodes: Array = pool.get(node_path, [])
	
	var node = load(String(node_path))
	if node == null:
		LOG.err("[PoolManager] Resource doesn't exist for path: " + node_path)
		return null
	var instance = node.instance()
	nodes.append(instance)
	pool[node_path] = nodes
	
	LOG.l("[PoolManager]" + String(nodes.size()) + " instances of: " + node_path)
	return instance
	
func get_node_instance(node_path: NodePath):
	var nodes: Array = pool.get(node_path, [])
	var node
	
	for n in nodes:
		if not in_use.has(n):
			node = n
			break
			
	if node == null:
		LOG.l("[PoolManager] Creating new resource instance: " + node_path)
		node = add_node(node_path)
	else:
		LOG.l("[PoolManager] Reusing resource instance: " + node_path)
	
	if node == null:
		LOG.err("[PoolManager] Failed to instantiate resource: " + node_path)
		return null
	
	in_use.append(node)
	return node
	
func release_node_instance(node: Spatial):
	var index = in_use.find(node)
	if index >= 0:
		in_use.remove(index)
		
func free_unused():
	print("[PoolManager] Removing unused nodes from pool (if any)")
	var count: int = 0
	for nodeArray in pool.values():
		for i in range(nodeArray.size()):
			var node = nodeArray[i]
			if not in_use.has(node):
				count += 1
				nodeArray.remove(i)
				node.free()
	print("[PoolManager] Removed " + String(count) + " unused node(s) from pool")
	
