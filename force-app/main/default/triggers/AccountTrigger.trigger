trigger AccountTrigger on Account (after insert) {
    System.debug('After Insert on Account');
}