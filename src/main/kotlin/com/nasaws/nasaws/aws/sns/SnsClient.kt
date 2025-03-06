package com.nasaws.nasaws.aws.sns

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import software.amazon.awssdk.services.sns.model.ListSubscriptionsByTopicRequest
import software.amazon.awssdk.services.sns.model.PublishRequest
import software.amazon.awssdk.services.sns.model.PublishResponse
import software.amazon.awssdk.services.sns.model.Subscription

@Service
class SnsClient(
    @Value("\${sns.topicArn}") private val snsDefaultTopicArn: String,
    snsConfig: SnsConfig
) {
    private val loggerFactory = LoggerFactory.getLogger(this::class.java)

    var client = snsConfig.getSnsClient()

    fun listTopicSubscriptions(): List<Subscription> {
        return try {
            val subscriptionsRequest = ListSubscriptionsByTopicRequest.builder()
                .topicArn(snsDefaultTopicArn)
                .build()

            client.listSubscriptionsByTopic(subscriptionsRequest).subscriptions()
        } catch (ex: Exception) {
            loggerFactory.warn("Couldn't get subscriptions")
            throw ex
        }
    }

    fun sendMessageToTopic(message: String): PublishResponse {
        try {
            val publishMessageRequest = PublishRequest.builder()
                .topicArn(snsDefaultTopicArn)
                .message(message)
                .build()

            val response = client.publish(publishMessageRequest)

            return response
        } catch (ex: Exception) {
            loggerFactory.error("Error occurred while publishing message to SNS", ex)

            throw ex
        }
    }


}