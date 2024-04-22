

namespace api_app_notes.Model.DTO
{
    public class NotesDTO
    {
        public int NoteId { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public string Day { get; set; }
        public string Time { get; set; }
        public string Pass { get; set; }
        public bool IsPinned { get; set; }
        public string Email { get; set; }
    }
}
