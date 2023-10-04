import { Redis } from "ioredis"
import crypto from "crypto"

const serverId = crypto.randomBytes(16).toString "hex"

export const redis = await new Redis process.env.REDIS_URL, 
	retryStrategy: do Math.min $1 * 50, 2000

export const padlock =
	def lock key, ttl
		const result = await redis.set key, serverId, "EX", ttl, "NX"
		result is "OK"
	
	def unlock key
		const script = '''
		if redis.call("get",KEYS[1]) == ARGV[1] then
			return redis.call("del",KEYS[1])
		else
			return 0
		end
		'''

		const result = await redis.eval script, 1, key, serverId
		result is 1
