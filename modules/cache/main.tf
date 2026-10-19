resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.name_prefix}-redis-subnet-${var.environment}"
  subnet_ids = var.private_subnet_ids
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.name_prefix}-redis-${var.environment}"
  description                = "Redis cluster for ${var.name_prefix} ${var.environment}"
  engine                     = "redis"
  node_type                  = var.node_type
  num_cache_clusters         = var.node_count
  automatic_failover_enabled = var.node_count >= 2
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
}
