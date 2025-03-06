package com.nasaws.nasaws.aws.sns

import java.net.URI
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.sns.SnsClient

@Service
class SnsConfig(
    @Value("\${spring.profiles.active}") private var activeProfiles: String = "default",
    @Value("\${localstack.endpoint}") private var localStackEndpoint: String? = "",
    @Value("\${aws.region}") private var awsRegion: Region
) {

    fun getSnsClient(): SnsClient {
        val builder = SnsClient
            .builder()
            .region(awsRegion)

        activeProfiles?.let {
            if (it == "dev") {
                builder.endpointOverride(localStackEndpoint?.let { localStack -> URI(localStack) })
            }
        }

        return builder.build()
    }

}
